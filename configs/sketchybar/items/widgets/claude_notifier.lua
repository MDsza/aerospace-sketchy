-- Claude Code Notifier Widget
-- Shows pulsing indicator when Claude Code is waiting for user input
-- Works GLOBALLY for all Claude Code sessions (any project, any terminal)
-- Auto-dismisses when VS Code becomes the active window (intelligent focus detection)

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Create the widget (initially hidden)
local claude_notifier = sbar.add("item", "widgets.claude_notifier", {
  position = "right",
  icon = {
    string = icons.claude or "􀌥",
    color = colors.orange,
    font = {
      style = settings.font.style_map["Regular"],
      size = 12.0,
    },
  },
  label = {
    drawing = false,
  },
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 0,
  },
  padding_left = 5,
  padding_right = 5,
  drawing = false,
})

-- Flag file to check
local FLAG_FILE = "/tmp/claude-waiting-flag"

-- Polling function via routine subscription
claude_notifier:subscribe("routine", function()
  -- Single shell command that checks BOTH flag file AND focused app
  -- Performance optimized: Aerospace query only runs when notification is active
  -- Returns: "waiting", "ready", "dismiss", or "missing"
  local check_cmd = 'FLAG_STATE=$([ -f ' .. FLAG_FILE .. ' ] && cat ' .. FLAG_FILE .. ' || echo "missing"); '
    .. 'if [ "$FLAG_STATE" = "waiting" ] || [ "$FLAG_STATE" = "ready" ]; then '
    .. '  FOCUSED_APP=$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null || echo "unknown"); '
    .. '  if [ "$FOCUSED_APP" = "Code" ]; then '
    .. '    rm -f ' .. FLAG_FILE .. '; '
    .. '    echo "dismiss"; '
    .. '  else '
    .. '    echo "$FLAG_STATE"; '
    .. '  fi; '
    .. 'else '
    .. '  echo "$FLAG_STATE"; '
    .. 'fi'

  sbar.exec(check_cmd, function(result)
    local state = result:match("(%w+)")

    if state == "waiting" then
      -- Claude is waiting for input - orange pulsing
      claude_notifier:set({
        drawing = true,
        icon = { color = colors.orange }
      })
      -- Trigger pulsing animation
      sbar.animate("sin", 30, function()
        claude_notifier:set({ icon = { color = { alpha = 0.3 } } })
      end)
      sbar.animate("sin", 30, function()
        claude_notifier:set({ icon = { color = { alpha = 1.0 } } })
      end)
    elseif state == "ready" then
      -- Claude finished - green solid (no pulsing)
      claude_notifier:set({
        drawing = true,
        icon = { color = colors.green }
      })
    else
      -- Flag file missing or auto-dismissed - hide widget
      claude_notifier:set({
        drawing = false,
        icon = { color = { alpha = 1.0 } }
      })
    end
  end)
end)

-- Update every 2 seconds
claude_notifier:set({ update_freq = 2, updates = true })

-- Click handler: Focus VS Code window AND clear notification
claude_notifier:subscribe("mouse.clicked", function(env)
  -- Open VS Code
  sbar.exec("open -a 'Visual Studio Code'")

  -- Clear the flag file to hide widget
  sbar.exec("rm -f " .. FLAG_FILE)

  -- Immediately hide widget
  claude_notifier:set({ drawing = false })
end)

return claude_notifier
