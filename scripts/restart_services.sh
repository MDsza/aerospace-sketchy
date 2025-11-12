#!/bin/bash
# Aerospace + Sketchybar Neustart (FUNKTIONIERENDE METHODE)

# Zeige Benachrichtigung
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Aerospace Neustart"'

# Stoppe brew services ERST
brew services stop sketchybar 2>/dev/null

# Force Kill alles
pkill -9 AeroSpace 2>/dev/null
killall -9 sketchybar 2>/dev/null
killall -9 lua 2>/dev/null
pkill -9 -f "sketchybar" 2>/dev/null

# Remove Lock-File
rm -f /tmp/sketchybar_wolfgang.lock 2>/dev/null

# Warte auf sauberes Beenden
sleep 3

# Starte neu via BREW SERVICES
brew services start sketchybar

# Warte auf vollständigen Sketchybar-Start
sleep 3

# Starte Aerospace neu
open -a AeroSpace

# Warte auf vollständigen Start
sleep 2

# Bestätigung
osascript -e 'display notification "Aerospace + Sketchybar Neustart abgeschlossen!" with title "Aerospace Neustart"'