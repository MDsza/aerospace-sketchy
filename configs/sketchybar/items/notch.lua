local settings = require("settings")

-- Reserve space for the MacBook notch by adding a center spacer
-- Set settings.notch_width to 0 to disable or tune the value to match your display
local width = tonumber(settings.notch_width or 0) or 0
if width > 0 then
  sbar.add("item", "notch.spacer", {
    position = "center",
    width = width,
    icon = { drawing = false },
    label = { drawing = false },
    background = { drawing = false },
  })
end

