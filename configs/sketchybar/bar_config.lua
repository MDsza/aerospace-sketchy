-- Zentrale SketchyBar-Konfiguration
-- Diese Datei definiert alle wichtigen SketchyBar-Parameter zentral

local bar_config = {}

-- SketchyBar Höhe in Pixeln
-- Diese Variable sollte mit der in bar_config.sh synchron sein
bar_config.height = 30

-- Weitere zentrale SketchyBar-Einstellungen
bar_config.position = "bottom"  -- "top" oder "bottom"
bar_config.display = "all"      -- "all", "main", oder spezifische Display-Nummer

-- Farben und Styling (können hier zentral verwaltet werden)
bar_config.margin = 0
bar_config.padding_right = 0
bar_config.padding_left = 0
bar_config.border_width = 0
bar_config.shadow = false
bar_config.y_offset = 0
bar_config.topmost = true
bar_config.sticky = true

return bar_config
