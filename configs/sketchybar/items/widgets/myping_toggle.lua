-- MyPing Skill Toggle Widget
-- Enables/disables Claude Code auto-notifications via myping-notify skill
-- Click to toggle between enabled/disabled state

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Project path detection (same as used in other scripts)
local HOME = os.getenv("HOME")
local PROJECT_PATH = HOME .. "/MyCloud/TOOLs/aerospace+sketchy"

-- Create the widget (always visible)
local myping_toggle = sbar.add("item", "widgets.myping_toggle", {
  position = "right",
  icon = {
    string = icons.bell.enabled,  -- Initial state (will be updated)
    color = colors.green,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,  -- Same as battery/volume
    },
    y_offset = -6,  -- Bottom alignment like battery/volume
  },
  label = {
    drawing = false,  -- Icon-only display
  },
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 0,
  },
  padding_left = 5,
  padding_right = 5,
  drawing = true,  -- Always visible
})

-- Paths to check
local MODE_FILE = HOME .. "/.config/myping/mode"

-- Function to update widget based on current mode
local function update_widget()
  -- Read mode from config file (immediate/delayed/off)
  local check_cmd = 'cat "' .. MODE_FILE .. '" 2>/dev/null || echo "off"'

  sbar.exec(check_cmd, function(result)
    local mode = result:match("(%w+)")

    if mode == "immediate" then
      -- Immediate mode - green bell (60% opacity)
      myping_toggle:set({
        icon = {
          string = icons.bell.enabled,
          color = colors.with_alpha(colors.green, 0.6)
        }
      })
    elseif mode == "delayed" then
      -- Delayed mode - blue bell (40% opacity)
      myping_toggle:set({
        icon = {
          string = icons.bell.enabled,
          color = colors.with_alpha(colors.blue, 0.4)
        }
      })
    else
      -- Off mode - grey bell with slash (full opacity)
      myping_toggle:set({
        icon = {
          string = icons.bell.disabled,
          color = colors.grey
        }
      })
    end
  end)
end

-- Subscribe to custom trigger (sent by toggle script)
myping_toggle:subscribe("myping_update", update_widget)

-- Routine check every 5 seconds (in case manual changes are made)
myping_toggle:subscribe("routine", update_widget)
myping_toggle:set({ update_freq = 5, updates = true })

-- Click handler: Execute toggle script
myping_toggle:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "left" then
    -- Execute toggle script
    sbar.exec(PROJECT_PATH .. "/scripts/toggle-myping-skill.sh")
  end
end)

-- Initial update
update_widget()

return myping_toggle
