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
local workspace_visual_state = {}    -- Cache last applied drawing/color/highlight per workspace
local workspace_icon_labels = {}     -- Cache last label string per workspace
local last_workspace_counts = {}     -- Track previous counts for differential dimming
local workspace_nav_order = {}       -- Current monitor-aware navigation order
local DEFAULT_NAV_ORDER = { "Q", "W", "E", "R", "T", "A", "S", "D", "F", "G" }
local CENTER_MOUSE_SCRIPT = "/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh"

-- Performance optimization
local last_focused_workspace = nil   -- Track last focused to do differential updates
local refresh_debounce_pending = false  -- Debounce for workspace_force_refresh

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

-- Cache-aware visibility update to avoid redundant Sketchybar set calls
local function update_workspace_visuals(ws_name, target_color, is_focused)
  local current_state = workspace_visual_state[ws_name]
  local needs_draw_change = not current_state or current_state.drawing ~= "on"
  local needs_color_change = not current_state or current_state.icon_color ~= target_color
  local needs_focus_change = not current_state or current_state.is_focused ~= is_focused

  if needs_draw_change or needs_color_change or needs_focus_change then
    local payload = {
      drawing = "on",
      icon = {
        color = target_color,
        highlight = is_focused,
        font = is_focused and {
          family = "SF Pro Display",
          style = "Black",
          size = 14.0
        } or {
          family = settings.font.numbers,
          style = settings.font.style_map["Regular"],
          size = 12.0
        }
      },
      label = { highlight = is_focused }
    }
    if spaces[ws_name] then
      spaces[ws_name]:set(payload)
    end
  end

  if space_paddings[ws_name] then
    local padding_state = current_state and current_state.padding_drawing or nil
    if padding_state ~= "on" then
      space_paddings[ws_name]:set({ drawing = "on" })
    end
  end

  workspace_visual_state[ws_name] = {
    drawing = "on",
    icon_color = target_color,
    padding_drawing = "on",
    is_focused = is_focused,
  }
end

local function copy_counts_table(source)
  local copy = {}
  for ws, count in pairs(source) do
    copy[ws] = count
  end
  return copy
end

local function update_navigation_order_from_groups(monitor_groups)
  local order = {}
  for _, monitor_id in ipairs(monitor_groups.monitor_order) do
    local group = monitor_groups.groups[monitor_id]
    for _, ws in ipairs(group.workspaces) do
      if ws:match("^[QWERTASDFGXYZ]$") then
        table.insert(order, ws)
      end
    end
  end
  workspace_nav_order = order
end

local function get_navigation_order()
  if workspace_nav_order and #workspace_nav_order > 0 then
    return workspace_nav_order
  end
  return DEFAULT_NAV_ORDER
end

local function build_navigation_candidates(focused_workspace)
  local order = get_navigation_order()
  local candidates = {}
  for _, ws in ipairs(order) do
    local count = workspace_window_counts[ws] or 0
    if count > 0 or ws == focused_workspace then
      table.insert(candidates, ws)
    end
  end
  if #candidates == 0 then
    for _, ws in ipairs(order) do
      table.insert(candidates, ws)
    end
  end
  return candidates
end

local function navigate_workspace(direction)
  local focused = last_focused_workspace or "Q"
  local candidates = build_navigation_candidates(focused)
  if #candidates == 0 then
    return
  end

  local current_index = 1
  for i, ws in ipairs(candidates) do
    if ws == focused then
      current_index = i
      break
    end
  end

  local target_index = ((current_index - 1 + direction) % #candidates) + 1
  local target = candidates[target_index]

  if not target or target == focused then
    return
  end

  sbar.exec("aerospace workspace " .. target)
end

local function apply_workspace_color(ws_name, focused_workspace)
  if not spaces[ws_name] then
    return
  end

  local count = workspace_window_counts[ws_name] or 0
  local is_focused = ws_name == focused_workspace
  local has_windows = count > 0
  local target_color = has_windows and (is_focused and 0xffffffff or 0xffcad3f5)
    or (is_focused and 0xffffffff or 0xff6e6e6e)

  update_workspace_visuals(ws_name, target_color, is_focused)
end

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
  update_freq = 30,  -- Increased from 2s to 30s (reduce event spam!)
})
-- DISABLE routine refresh - only refresh on explicit window events
-- space_window_observer:subscribe("routine", function()
--   sbar.trigger("workspace_force_refresh")
-- end)
space_window_observer:subscribe("window_created", function(env)
  sbar.trigger("workspace_force_refresh")
end)
space_window_observer:subscribe("window_destroyed", function(env)
  sbar.trigger("workspace_force_refresh")
end)

-- ULTRA-OPTIMIZED: INSTANT workspace change handler (NO queries, NO delays!)
space_window_observer:subscribe("aerospace_workspace_change", function(env)
  local new_focused = env.FOCUSED_WORKSPACE

  -- Create workspace item if it doesn't exist yet
  if not known_workspaces[new_focused] then
    create_workspace_item(new_focused)
  end

  -- INSTANT UPDATE: Only visual state (color/highlight) for 2 workspaces!
  -- NO queries, NO topology checks, NO window counts
  if last_focused_workspace and last_focused_workspace ~= new_focused then
    -- Old workspace: unhighlight (keep current color - will update on next force_refresh)
    if spaces[last_focused_workspace] then
      spaces[last_focused_workspace]:set({
        icon = {
          highlight = false,
          font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Regular"],
            size = 12.0
          }
        },
        label = { highlight = false }
      })
    end
  end

  -- New workspace: highlight white
  if spaces[new_focused] then
    spaces[new_focused]:set({
      icon = {
        color = 0xffffffff,  -- Always white when focused
        highlight = true,
        font = {
          family = "SF Pro Display",
          style = "Black",
          size = 14.0
        }
      },
      label = { highlight = true }
    })
  end

  last_focused_workspace = new_focused
end)

-- OPTIMIZED: Debounced window event handler (icon updates only)
space_window_observer:subscribe("workspace_force_refresh", function(env)
  -- Debounce: Skip if already pending
  if refresh_debounce_pending then
    return
  end

  refresh_debounce_pending = true

  -- 150ms delay for Aerospace state update (window move events)
  sbar.delay(0.15, function()
    refresh_debounce_pending = false

    -- Force cache refresh for move events (query_with_monitors has no cache, but clear anyway)
    aerospace_batch:refresh()

    aerospace_batch:query_with_monitors(function(batch_data)
      if not batch_data or not batch_data.workspaces or not batch_data.windows then
        return
      end

      -- Build shared state
      build_workspace_window_counts(batch_data)

      -- Monitor topology check (only if changed)
      local topology_changed = has_monitor_topology_changed(batch_data)
      if topology_changed then
        local monitor_groups = group_workspaces_by_monitor(batch_data)
        update_navigation_order_from_groups(monitor_groups)
        execute_reorder_with_queue(monitor_groups, batch_data.focused_workspace, batch_data)
      end

      -- Update colors only for workspaces whose window count changed
      local processed = {}
      for ws_name, count in pairs(workspace_window_counts) do
        processed[ws_name] = true
        if last_workspace_counts[ws_name] ~= count then
          apply_workspace_color(ws_name, batch_data.focused_workspace)
        end
      end
      for ws_name, _ in pairs(last_workspace_counts) do
        if not processed[ws_name] then
          workspace_window_counts[ws_name] = 0
          apply_workspace_color(ws_name, batch_data.focused_workspace)
        end
      end
      last_workspace_counts = copy_counts_table(workspace_window_counts)

      -- ONLY UPDATE ICONS (color updates handled above)
      for _, workspace_info in ipairs(batch_data.workspaces) do
        local workspace_name = workspace_info.name

        -- Skip if workspace item doesn't exist yet
        if not spaces[workspace_name] then
          goto continue
        end

        -- Build app icons
        local icon_line = ""
        local apps = {}

        for _, window in ipairs(batch_data.windows) do
          if window.workspace == workspace_name then
            local app = window.app or "Unknown"
            apps[app] = (apps[app] or 0) + 1
          end
        end

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

        -- Update label only if changed (cache check)
        if workspace_icon_labels[workspace_name] ~= icon_line then
          workspace_icon_labels[workspace_name] = icon_line
          spaces[workspace_name]:set({ label = icon_line })
        end

        ::continue::
      end
    end)
  end)
end)

-- Event-driven workspace navigation (Hyper+N/M)
space_window_observer:subscribe("workspace_nav_next", function()
  navigate_workspace(1)
end)

space_window_observer:subscribe("workspace_nav_prev", function()
  navigate_workspace(-1)
end)

-- WINDOW NAVIGATION (Hyper+J/L): Now uses native AeroSpace DFS commands
-- Directly bound in aerospace.toml: 'focus --boundaries-action wrap-around-the-workspace dfs-prev/next'
-- DFS (Depth-First Search) follows window tree structure: top→bottom, left→right
-- No event handlers needed - navigation is instant via aerospace.toml bindings

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

  -- Initialize last_focused_workspace for differential updates
  last_focused_workspace = batch_data.focused_workspace

  -- Trigger initial workspace change event
  if batch_data.focused_workspace then
    sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = batch_data.focused_workspace })
  end
end)
