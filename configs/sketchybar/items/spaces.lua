local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local aerospace_batch = require("helpers.aerospace_batch")

local spaces = {}
local space_paddings = {}  -- Track padding items for dynamic hiding
local known_workspaces = {}

-- State for monitor-based grouping
local last_monitor_assignments = {}  -- workspace → monitor_id (Change-Detection)
local separator_item = nil           -- Reference zum Separator-Item
local reorder_pending = false        -- Debounce-Lock
local pending_reorder_data = nil     -- Queued reorder if pending=true
local workspace_window_counts = {}   -- workspace → window_count (shared state!)

-- Workspace labels (QWERTZ Layout + Overflow X/Y/Z)
local workspace_labels = {
  -- Row 1
  Q = "Q",
  W = "W",
  E = "E",
  R = "R",
  T = "T",
  -- Row 2
  A = "A",
  S = "S",
  D = "D",
  F = "F",
  G = "G",
  -- Overflow workspaces (multi-monitor)
  X = "X",
  Y = "Y",
  Z = "Z"
}

-- Sort function (QWERTZ Layout order: Q W E R T A S D F G X Y Z, then numbers)
local function workspace_sort_key(name)
  -- QWERTZ workspace order mapping
  local qwertz_order = {
    Q = "01", W = "02", E = "03", R = "04", T = "05",
    A = "06", S = "07", D = "08", F = "09", G = "10",
    X = "11", Y = "12", Z = "13"  -- Overflow workspaces
  }

  -- Check if it's a QWERTZ/XYZ workspace
  if qwertz_order[name] then
    return "0" .. qwertz_order[name]  -- QWERTZ + XYZ first
  end

  -- Numeric workspaces come after QWERTZ/XYZ
  local num = tonumber(name)
  if num then
    return string.format("1%03d", num)
  end

  -- Any other workspaces (fallback)
  return "2" .. name
end

-- Helper: Build shared window counts state
local function build_workspace_window_counts(batch_data)
  workspace_window_counts = {}  -- Reset
  for _, win in ipairs(batch_data.windows) do
    local ws = win.workspace
    workspace_window_counts[ws] = (workspace_window_counts[ws] or 0) + 1
  end
end

-- Helper: Group workspaces by monitor
local function group_workspaces_by_monitor(batch_data)
  local groups = {}
  local monitor_order = {}

  -- Sort monitors: Built-in first, then by ID
  local sorted_monitors = {}
  for _, mon in ipairs(batch_data.monitors) do
    table.insert(sorted_monitors, mon)
  end
  table.sort(sorted_monitors, function(a, b)
    if a.is_builtin ~= b.is_builtin then
      return a.is_builtin  -- Built-in first
    end
    return a.id < b.id
  end)

  -- Build monitor_order and groups structure
  for _, mon in ipairs(sorted_monitors) do
    table.insert(monitor_order, mon.id)
    groups[mon.id] = {
      workspaces = {},
      name = mon.name,
      is_builtin = mon.is_builtin
    }
  end

  -- Group workspaces by monitor_id
  for _, ws_info in ipairs(batch_data.workspaces) do
    local mid = ws_info.monitor_id
    if groups[mid] then
      table.insert(groups[mid].workspaces, ws_info.name)
    end
  end

  -- Sort workspaces within each group by QWERTZ order
  for _, group_data in pairs(groups) do
    table.sort(group_data.workspaces, function(a, b)
      return workspace_sort_key(a) < workspace_sort_key(b)
    end)
  end

  return {
    monitor_order = monitor_order,
    groups = groups
  }
end

-- Helper: Check if monitor topology changed
local function has_monitor_topology_changed(batch_data)
  for _, ws_info in ipairs(batch_data.workspaces) do
    if last_monitor_assignments[ws_info.name] ~= ws_info.monitor_id then
      return true
    end
  end
  return false
end

-- Helper: Update monitor assignments state (after successful reorder)
local function update_monitor_assignments_state(batch_data)
  for _, ws_info in ipairs(batch_data.workspaces) do
    last_monitor_assignments[ws_info.name] = ws_info.monitor_id
  end
end

-- Helper function to create monitor separator
local function create_monitor_separator()
  if not separator_item then  -- Create only once!
    separator_item = sbar.add("item", "workspace.separator", {
      position = "left",
      icon = {
        string = "│",
        color = colors.grey,
        font = { size = 20.0 }
      },
      label = { drawing = false },
      background = { drawing = false },
      padding_left = 8,
      padding_right = 8,
    })
  end
  return separator_item
end

-- Forward declaration (needed for recursive call in execute_reorder_with_queue)
local reorder_items_by_monitor_groups
local execute_reorder_with_queue

-- Helper function to ensure workspace items exist before reorder
local function ensure_workspace_items_exist(workspace_names)
  for _, ws_name in ipairs(workspace_names) do
    if not known_workspaces[ws_name] then
      -- First time seeing this workspace -> create items
      create_workspace_item(ws_name)
    end
  end
end

-- Helper function to create a workspace item dynamically
local function create_workspace_item(workspace_name)
  -- Check if already exists
  if spaces[workspace_name] then
    return spaces[workspace_name]
  end

  -- IMPORTANT: Use "item" NOT "space" - Aerospace workspaces are virtual, not macOS Spaces
  local space = sbar.add("item", "space." .. workspace_name, {
    position = "left",
    icon = {
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Regular"]
      },
      -- Use label for letter workspaces, number for numeric
      string = workspace_labels[workspace_name] or workspace_name,
      padding_left = 3,
      padding_right = 3,
      color = colors.white,
      highlight_color = 0xffffffff,
    },
    label = {
      padding_right = 12,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.transparent,
      drawing = false,
      border_width = 0,
      height = 20,
      border_color = colors.transparent,
    },
    popup = { background = { border_width = 0, border_color = colors.transparent, drawing = false } }
  })

  spaces[workspace_name] = space
  known_workspaces[workspace_name] = true

  -- Padding item
  local padding = sbar.add("item", "space.padding." .. workspace_name, {
    position = "left",
    script = "",
    width = settings.group_paddings,
  })
  space_paddings[workspace_name] = padding

  local space_popup = sbar.add("item", {
    position = "popup." .. space.name,
    padding_left= 5,
    padding_right= 0,
    background = {
      drawing = false,
      color = colors.transparent,
      image = {
        corner_radius = 9,
        scale = 0.2
      }
    }
  })

  -- Subscribe to Aerospace workspace change event
  space:subscribe("aerospace_workspace_change", function(env)
    local focused_workspace = env.FOCUSED_WORKSPACE
    local selected = (focused_workspace == workspace_name)

    space:set({
      icon = {
        highlight = selected,
        font = selected and {
          family = "SF Pro Display",
          style = "Black",
          size = 14.0
        } or {
          family = settings.font.numbers,
          style = settings.font.style_map["Regular"],
          size = 12.0
        }
      },
      label = { highlight = selected },
      background = { border_color = colors.transparent }
    })
  end)

  -- Mouse click handler for Aerospace
  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "other" then
      space_popup:set({ background = { image = "space." .. workspace_name } })
      space:set({ popup = { drawing = "toggle" } })
    else
      -- Focus workspace via Aerospace
      sbar.exec("aerospace workspace " .. workspace_name)
    end
  end)

  space:subscribe("mouse.exited", function(_)
    space:set({ popup = { drawing = false } })
  end)

  return space
end

-- Reorder workspace items by monitor groups (differential update)
function reorder_items_by_monitor_groups(monitor_groups, focused_workspace)
  -- Ensure separator exists
  create_monitor_separator()

  -- Build flat ordered list from monitor_groups
  local ordered_workspaces = {}
  local separator_position = -1

  for i, monitor_id in ipairs(monitor_groups.monitor_order) do
    local group = monitor_groups.groups[monitor_id]
    for _, ws in ipairs(group.workspaces) do
      table.insert(ordered_workspaces, ws)
    end

    -- Insert separator after first monitor group (if multi-monitor)
    if i == 1 and #monitor_groups.monitor_order > 1 then
      separator_position = #ordered_workspaces
    end
  end

  -- Ensure all workspace items exist (handles new Overflow X/Y/Z)
  ensure_workspace_items_exist(ordered_workspaces)

  -- Build reorder command: interleave main + padding items
  local all_items = {}
  for i, ws in ipairs(ordered_workspaces) do
    -- Add main item first, then padding (preserves original creation order)
    if spaces[ws] then
      table.insert(all_items, spaces[ws].name)
    end
    if space_paddings[ws] then
      table.insert(all_items, space_paddings[ws].name)
    end

    -- Insert separator after first monitor group
    if i == separator_position then
      table.insert(all_items, separator_item.name)
    end
  end

  -- Execute single reorder for all items
  if #all_items > 0 then
    sbar.exec("sketchybar --reorder " .. table.concat(all_items, " "))
  end

  -- Update separator visibility
  local visible_monitor_count = 0
  for monitor_id, group in pairs(monitor_groups.groups) do
    local has_visible = false
    for _, ws in ipairs(group.workspaces) do
      if (workspace_window_counts[ws] or 0) > 0 or ws == focused_workspace then
        has_visible = true
        break
      end
    end
    if has_visible then
      visible_monitor_count = visible_monitor_count + 1
    end
  end

  separator_item:set({drawing = (visible_monitor_count > 1) and "on" or "off"})
end

-- Execute reorder with queue-based debounce
function execute_reorder_with_queue(monitor_groups, focused_workspace, batch_data)
  if reorder_pending then
    -- Queue this reorder for later execution
    pending_reorder_data = {
      monitor_groups = monitor_groups,
      focused_workspace = focused_workspace,
      batch_data = batch_data
    }
    return  -- Don't execute now
  end

  -- Execute reorder
  reorder_pending = true
  reorder_items_by_monitor_groups(monitor_groups, focused_workspace)
  update_monitor_assignments_state(batch_data)

  -- Release lock after 100ms + execute queued reorder if exists
  sbar.delay(0.1, function()
    reorder_pending = false

    -- Execute queued reorder if one was pending
    if pending_reorder_data then
      local queued = pending_reorder_data
      pending_reorder_data = nil
      execute_reorder_with_queue(queued.monitor_groups, queued.focused_workspace, queued.batch_data)
    end
  end)
end


local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
  update_freq = 2,
})
space_window_observer:subscribe("routine", function()
  sbar.trigger("workspace_force_refresh")
end)
space_window_observer:subscribe("window_created", function(env)
  sbar.trigger("workspace_force_refresh")
end)
space_window_observer:subscribe("window_destroyed", function(env)
  sbar.trigger("workspace_force_refresh")
end)

-- Window change observer with dynamic workspace discovery
space_window_observer:subscribe("aerospace_workspace_change", function(env)
  aerospace_batch:refresh()

  -- Query with monitor information for dynamic workspace discovery
  aerospace_batch:query_with_monitors(function(batch_data)
    if not batch_data or not batch_data.workspaces or not batch_data.windows then
      return
    end

    -- Discover and create new workspaces dynamically
    local workspaces_to_create = {}  -- Track workspaces that should be created

    -- First pass: Filter and categorize workspaces
    for _, workspace_info in ipairs(batch_data.workspaces) do
      local ws_name = workspace_info.name

      -- SOFT-DELETE FILTER: Count windows on this workspace
      local window_count = 0
      for _, window in ipairs(batch_data.windows) do
        if window.workspace == ws_name then
          window_count = window_count + 1
          break  -- Found at least one window
        end
      end

      -- Skip empty workspaces (unless it's a QWERTZ/XYZ workspace or currently focused)
      local is_qwertz_workspace = ws_name:match("^[QWERTASDFGXYZ]$")
      local is_focused = ws_name == batch_data.focused_workspace

      if window_count == 0 and not is_qwertz_workspace and not is_focused then
        -- Don't create/show empty numeric workspaces (soft-delete)
        goto continue
      end

      -- Track that this workspace should be created
      table.insert(workspaces_to_create, ws_name)

      ::continue::
    end

    -- Build shared state FIRST (used by visibility + separator)
    build_workspace_window_counts(batch_data)

    -- Check if monitor topology changed
    local monitor_groups = group_workspaces_by_monitor(batch_data)
    local topology_changed = has_monitor_topology_changed(batch_data)

    if topology_changed then
      execute_reorder_with_queue(monitor_groups, batch_data.focused_workspace, batch_data)
    end

    -- Sort function (QWERTZ Layout order: Q W E R T A S D F G X Y Z, then numbers)
    local function workspace_sort_key(name)
      -- QWERTZ workspace order mapping
      local qwertz_order = {
        Q = "01", W = "02", E = "03", R = "04", T = "05",
        A = "06", S = "07", D = "08", F = "09", G = "10",
        X = "11", Y = "12", Z = "13"  -- Overflow workspaces
      }

      -- Check if it's a QWERTZ/XYZ workspace
      if qwertz_order[name] then
        return "0" .. qwertz_order[name]  -- QWERTZ + XYZ first
      end

      -- Numeric workspaces come after QWERTZ/XYZ
      local num = tonumber(name)
      if num then
        return string.format("1%03d", num)
      end

      -- Any other workspaces (fallback)
      return "2" .. name
    end

    -- Sort all workspaces to create
    table.sort(workspaces_to_create, function(a, b)
      return workspace_sort_key(a) < workspace_sort_key(b)
    end)

    -- Second pass: Create workspaces in sorted order
    for _, ws_name in ipairs(workspaces_to_create) do
      if not known_workspaces[ws_name] then
        create_workspace_item(ws_name)
      end
    end

    -- DYNAMIC HIDING: Hide/show workspace items based on window count
    -- Use shared workspace_window_counts (already built via build_workspace_window_counts)

    -- Update visibility for all created workspace items
    for ws_name, space_item in pairs(spaces) do
      local has_windows = (workspace_window_counts[ws_name] or 0) > 0
      local is_focused = ws_name == batch_data.focused_workspace

      -- Show only if: has windows OR is currently focused
      -- Remove QWERTZ/XYZ exemption!
      local should_show = has_windows or is_focused

      space_item:set({ drawing = should_show and "on" or "off" })

      -- Also hide/show padding to avoid gaps
      if space_paddings[ws_name] then
        space_paddings[ws_name]:set({ drawing = should_show and "on" or "off" })
      end
    end

    -- Update all workspaces with app icons and highlighting
    for _, workspace_info in ipairs(batch_data.workspaces) do
      local workspace_name = workspace_info.name

      if spaces[workspace_name] then
        local icon_line = ""
        local apps = {}

        -- Collect apps for this workspace
        for _, window in ipairs(batch_data.windows) do
          if window.workspace == workspace_name then
            local app = window.app or "Unknown"
            apps[app] = (apps[app] or 0) + 1
          end
        end

        -- Generate icon line
        local no_app = true
        for app, count in pairs(apps) do
          no_app = false
          local lookup = app_icons[app]
          local icon = ((lookup == nil) and app_icons["Default"] or lookup)
          icon_line = icon_line .. icon
        end

        if no_app then
          icon_line = " —"
        end

        -- Update space display
        sbar.animate("tanh", 10, function()
          spaces[workspace_name]:set({ label = icon_line })
        end)
      end
    end
  end)
end)

-- Subscribe workspace_force_refresh to same handler (triggered by window_created, window_destroyed, app_launched, app_terminated)
space_window_observer:subscribe("workspace_force_refresh", function(env)
  aerospace_batch:refresh()

  -- Delay slightly so Aerospace state is consistent
  sbar.delay(0.15, function()
    aerospace_batch:query_with_monitors(function(batch_data)
      if not batch_data or not batch_data.workspaces or not batch_data.windows then
        return
      end

      -- Build shared state
      build_workspace_window_counts(batch_data)

      -- Lightweight monitor change check (with queue-based debounce!)
      local topology_changed = has_monitor_topology_changed(batch_data)

      if topology_changed then
        local monitor_groups = group_workspaces_by_monitor(batch_data)
        execute_reorder_with_queue(monitor_groups, batch_data.focused_workspace, batch_data)
      end

      -- Update app icons for all workspaces
      for _, workspace_info in ipairs(batch_data.workspaces) do
        local workspace_name = workspace_info.name

        -- Skip non-QWERTZ/XYZ workspaces
        if not workspace_name:match("^[QWERTASDFGXYZ]$") and not workspace_name:match("^%d+$") then
          goto continue
        end

        -- Skip if workspace item doesn't exist yet
        if not spaces[workspace_name] then
          goto continue
        end

        -- Build app icons for this workspace (same logic as aerospace_workspace_change)
        local icon_line = ""
        local apps = {}

        -- Collect apps for this workspace
        for _, window in ipairs(batch_data.windows) do
          if window.workspace == workspace_name then
            local app = window.app or "Unknown"
            apps[app] = (apps[app] or 0) + 1
          end
        end

        -- Generate icon line
        local no_app = true
        for app, count in pairs(apps) do
          no_app = false
          local lookup = app_icons[app]
          local icon = ((lookup == nil) and app_icons["Default"] or lookup)
          icon_line = icon_line .. icon
        end

        if no_app then
          icon_line = " —"
        end

        -- Update space label
        sbar.animate("tanh", 10, function()
          spaces[workspace_name]:set({ label = icon_line })
        end)

        ::continue::
      end
    end)
  end)
end)

-- Initial setup with dynamic workspace discovery
aerospace_batch:query_with_monitors(function(batch_data)
  if not batch_data or not batch_data.workspaces then
    return
  end

  -- Collect all workspaces
  local all_workspaces = {}
  for _, workspace_info in ipairs(batch_data.workspaces) do
    table.insert(all_workspaces, workspace_info.name)
  end

  -- QWERTZ Layout order: Q W E R T A S D F G X Y Z, then numbers
  local function workspace_sort_key(name)
    -- QWERTZ workspace order mapping
    local qwertz_order = {
      Q = "01", W = "02", E = "03", R = "04", T = "05",
      A = "06", S = "07", D = "08", F = "09", G = "10",
      X = "11", Y = "12", Z = "13"  -- Overflow workspaces
    }

    -- Check if it's a QWERTZ/XYZ workspace
    if qwertz_order[name] then
      return "0" .. qwertz_order[name]  -- QWERTZ + XYZ first
    end

    -- Numeric workspaces come after QWERTZ/XYZ
    local num = tonumber(name)
    if num then
      return string.format("1%03d", num)
    end

    -- Any other workspaces (fallback)
    return "2" .. name
  end

  -- Sort all workspaces in QWERTZ order
  table.sort(all_workspaces, function(a, b)
    return workspace_sort_key(a) < workspace_sort_key(b)
  end)

  -- Create workspace items in sorted order
  for _, ws_name in ipairs(all_workspaces) do
    create_workspace_item(ws_name)
  end

  -- Trigger initial workspace change event
  if batch_data.focused_workspace then
    sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = batch_data.focused_workspace })
  end
end)
