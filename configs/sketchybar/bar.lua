
local colors = require("colors")
local bar_config = require("bar_config")

-- Equivalent to the --bar domain
-- Verwendet zentrale Konfiguration für alle Bar-Einstellungen
sbar.bar({
  height = bar_config.height,
  color = colors.bar.bg,
  padding_right = bar_config.padding_right,
  padding_left = bar_config.padding_left,
  border_width = bar_config.border_width,
  border_color = colors.bar.bg,
  shadow = bar_config.shadow,
  display = bar_config.display,
  position = bar_config.position,
  topmost = bar_config.topmost,
  y_offset = bar_config.y_offset,
  margin = bar_config.margin,
  sticky = bar_config.sticky
})
