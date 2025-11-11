local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 9 } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 12.0
    },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 24,
    corner_radius = 0,
    border_width = 0,  -- Kein Rahmen
    color = colors.transparent,  -- Komplett transparent
    drawing = false,  -- Nicht zeichnen
    image = {
      corner_radius = 0,
      border_color = colors.transparent,
      border_width = 0
    }
  },
  popup = {
    background = {
      border_width = 0,
      corner_radius = 0,
      border_color = colors.transparent,
      color = colors.transparent,
      drawing = false,
      shadow = { drawing = false },
    },
    blur_radius = 0,
  },
  padding_left = 5,
  padding_right = 5,
  scroll_texts = true,
})
