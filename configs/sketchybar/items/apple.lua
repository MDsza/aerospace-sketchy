local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
-- Padding item required because of bracket
sbar.add("item", { position = "left", width = 5 })
local apple = sbar.add("item", "apple", {
  position = "left",
  icon = {
    font = { size = 16.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = {
    color = colors.transparent,
    drawing = false,
    border_color = colors.transparent,
    border_width = 0
  },
  padding_left = 1,
  padding_right = 1,
  click_script = "~/.config/sketchybar/plugins/apple_click_handler.sh"
})
-- Double border for apple using a single item bracket
sbar.add("bracket", { apple.name }, {
  background = {
    color = colors.transparent,
    drawing = false,
    height = 20,
    border_color = colors.transparent,
  }
})
-- Padding item required because of bracket
sbar.add("item", { position = "left", width = 7 })

-- Icon-Farbe-Sync bei aerospace_workspace_change (nach Sketchybar-Restart)
apple:subscribe("aerospace_workspace_change", function(env)
  local handle = io.popen("[ -f /tmp/aerospace-paused-state ] && echo 'paused' || echo 'active'")
  local state = handle:read("*a"):gsub("%s+", "")
  handle:close()

  if state == "paused" then
    sbar.set(apple, { icon = { color = 0xff6e6e6e } })  -- dunkelgrau
  else
    sbar.set(apple, { icon = { color = 0xffffffff } })  -- weiß
  end
end)