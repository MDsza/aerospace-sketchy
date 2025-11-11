return {
  black = 0xff181819,
  white = 0xffe2e2e3,
  red = 0xfffc5d7c,
  green = 0xff9ed072,
  blue = 0xff76cce0,
  cyan = 0xff00d4ff,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  dark_orange = 0xffff8c42,
  magenta = 0xffb39df3,
  grey = 0xff7f8490,
  transparent = 0x00000000,

  bar = {
    bg = 0xff000000,  -- Komplett schwarz
    border = 0xff000000,
  },
  popup = {
    bg = 0xc02c2e34,
    border = 0xff7f8490
  },
  bg1 = 0xff000000,  -- Schwarz statt grau
  bg2 = 0xff000000,  -- Schwarz statt grau

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
