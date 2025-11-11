local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local aerospace_batch = require("helpers.aerospace_batch")

local spaces = {}

-- Hybrid workspace system: 1-9 + E/T/C/B/M (fixed order)
local workspaces = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "E", "T", "C", "B", "M"}

-- Workspace labels (for letter workspaces) - using SF Symbols for macOS compatibility
local workspace_labels = {
  E = "􀍕",  -- Email (envelope.fill)
  T = "􀩼",  -- Terminal (app.terminal.fill)
  C = "􀤙",  -- Code (chevron.left.forwardslash.chevron.right)
  B = "􀎬",  -- Browser (safari.fill)
  M = "􀑪"   -- Media (play.fill)
}

for i, workspace_name in ipairs(workspaces) do
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

  -- Padding item
  sbar.add("item", "space.padding." .. workspace_name, {
    position = "left",
    script = "",
    width = settings.group_paddings,
  })

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

-- Window change observer using Aerospace batch system
space_window_observer:subscribe("aerospace_workspace_change", function(env)
  aerospace_batch:refresh()

  aerospace_batch:query_all(function(batch_data)
    if not batch_data or not batch_data.workspaces or not batch_data.windows then
      return
    end

    -- Update all workspaces
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

-- Initial trigger on startup to set correct workspace state
sbar.exec("aerospace list-workspaces --focused", function(focused_ws)
  if focused_ws and focused_ws ~= "" then
    local ws = focused_ws:match("^%s*(.-)%s*$")
    sbar.trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = ws })
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
