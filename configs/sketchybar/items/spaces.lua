local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local aerospace_batch = require("helpers.aerospace_batch")

local spaces = {}
local space_paddings = {}  -- Track padding items for dynamic hiding
local known_workspaces = {}

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


local space_window_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})

local spaces_indicator = sbar.add("item", {
  padding_left = -3,
  padding_right = 0,
  icon = {
    padding_left = 8,
    padding_right = 9,
    color = colors.grey,
    string = icons.switch.on,
  },
  label = {
    width = 0,
    padding_left = 0,
    padding_right = 8,
    string = "Spaces",
    color = colors.bg1,
  },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  }
})

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
    -- Build a map of workspaces with windows
    local workspaces_with_windows = {}
    for _, window in ipairs(batch_data.windows) do
      workspaces_with_windows[window.workspace] = true
    end

    -- Update visibility for all created workspace items
    for ws_name, space_item in pairs(spaces) do
      local has_windows = workspaces_with_windows[ws_name] == true
      local is_qwertz_workspace = ws_name:match("^[QWERTASDFGXYZ]$")
      local is_focused = ws_name == batch_data.focused_workspace

      -- Show if: has windows, is QWERTZ/XYZ workspace, or is currently focused
      -- Hide if: empty numeric workspace
      local should_show = has_windows or is_qwertz_workspace or is_focused

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

  -- Create Front App item AFTER all workspaces
  local front_app = sbar.add("item", "front_app", {
    position = "left",
    icon = { drawing = false },
    label = {
      font = {
        family = settings.font.text,
        style = settings.font.style_map["Bold"],
        size = 13.0,
      },
      color = colors.white,
      padding_left = 20,
      padding_right = 10,
    },
    background = {
      color = colors.transparent,
    },
    updates = true,
  })

  -- Update on front app switch
  front_app:subscribe("front_app_switched", function(env)
    front_app:set({ label = { string = env.INFO } })
  end)

  -- Update on workspace change
  front_app:subscribe("aerospace_workspace_change", function(env)
    sbar.exec("aerospace list-windows --focused --format '%{app-name}'", function(result)
      local app_name = result:match("^%s*(.-)%s*$")
      if app_name and app_name ~= "" then
        front_app:set({ label = { string = app_name } })
      else
        front_app:set({ label = { string = "—" } })
      end
    end)
  end)

  -- Click handler
  front_app:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
  end)

  -- Trigger initial workspace change event
  if batch_data.focused_workspace then
    sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = batch_data.focused_workspace })
  end
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = currently_on and icons.switch.off or icons.switch.on
  })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon = { color = colors.bg1 },
      label = { width = "dynamic" }
    })
  end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
  sbar.animate("tanh", 30, function()
    spaces_indicator:set({
      background = {
        color = { alpha = 0.0 },
        border_color = { alpha = 0.0 },
      },
      icon = { color = colors.grey },
      label = { width = 0, }
    })
  end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
