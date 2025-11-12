#!/bin/bash
# Aerospace + Sketchybar Neustart (KOMPLETT - Force Kill + Lock File Remove)

# Zeige Benachrichtigung
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Aerospace Neustart"'

# Force Kill Aerospace
pkill -9 AeroSpace 2>/dev/null

# Force Kill Sketchybar + Remove Lock File
pkill -9 sketchybar 2>/dev/null
pkill -9 -f "lua /Users/wolfgang/.config/sketchybar" 2>/dev/null
rm -f /tmp/sketchybar_$USER.lock 2>/dev/null

# Warte auf sauberes Beenden
sleep 2

# Starte Aerospace neu
open -a AeroSpace

# Warte kurz
sleep 1

# Starte Sketchybar neu
sketchybar

# Warte auf vollständigen Start
sleep 2

# Bestätigung
osascript -e 'display notification "Aerospace + Sketchybar Neustart abgeschlossen!" with title "Aerospace Neustart"'