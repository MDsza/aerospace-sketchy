#!/bin/bash
# Aerospace + Sketchybar Neustart

# Zeige Benachrichtigung
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Aerospace Neustart"'

# Starte Aerospace neu
killall AeroSpace 2>/dev/null
sleep 1
open -a AeroSpace

# Starte Sketchybar neu
killall sketchybar 2>/dev/null
sleep 1
sketchybar

# Kurz warten
sleep 2

# Bestätigung
osascript -e 'display notification "Aerospace + Sketchybar Neustart abgeschlossen!" with title "Aerospace Neustart"'