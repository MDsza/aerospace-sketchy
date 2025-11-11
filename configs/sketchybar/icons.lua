local settings = require("settings")

local icons = {
  sf_symbols = {
    plus = "􀅼",
    loading = "􀖇",
    apple = "􀣺",
    gear = "􀍟",
    cpu = "􀫥",
    clipboard = "􀉄",
    disk = "􀤂",
    network = "􀤆",
    ipad = "􀢨",  -- iPad SF Symbol

    bell = {
      enabled = "􀋚",   -- bell.fill
      disabled = "􀝖",  -- bell.slash.fill
    },

    switch = {
      on = "􁏮",
      off = "􁏯",
    },
    volume = {
      _100="􀊩",
      _66="􀊧",
      _33="􀊥",
      _10="􀊡",
      _0="􀊣",
    },
    battery = {
      _100 = "􀛨",
      _75 = "􀺸",
      _50 = "􀺶",
      _25 = "􀛩",
      _0 = "􀛪",
      charging = "􀢋"
    },
    wifi = {
      upload = "􀄨",
      download = "􀄩",
      connected = "􀙇",
      disconnected = "􀙈",
      router = "􁓤",
    },
    media = {
      back = "􀊊",
      forward = "􀊌",
      play_pause = "􀊈",
    },
    claude = "􀌥", -- Chat bubble filled for Claude Code notifications
  },

  -- Alternative NerdFont icons
  nerdfont = {
    plus = "",
    loading = "",
    apple = "",
    gear = "",
    cpu = "",
    clipboard = "Missing Icon",
    disk = "󰋊",
    network = "󰛳",
    ipad = "󰟠",  -- Tablet NerdFont icon

    bell = {
      enabled = "󰂚",   -- notification icon
      disabled = "󰂛",  -- notification off icon
    },

    switch = {
      on = "󱨥",
      off = "󱨦",
    },
    volume = {
      _100="",
      _66="",
      _33="",
      _10="",
      _0="",
    },
    battery = {
      _100 = "",
      _75 = "",
      _50 = "",
      _25 = "",
      _0 = "",
      charging = ""
    },
    wifi = {
      upload = "",
      download = "",
      connected = "󰖩",
      disconnected = "󰖪",
      router = "Missing Icon"
    },
    media = {
      back = "",
      forward = "",
      play_pause = "",
    },
  },
}

-- Ensure claude icon exists in both sets
icons.sf_symbols.claude = icons.sf_symbols.claude or "􀌥"
icons.nerdfont.claude = icons.nerdfont.claude or "󰘦"

if not (settings.icons == "NerdFont") then
  return icons.sf_symbols
else
  return icons.nerdfont
end
