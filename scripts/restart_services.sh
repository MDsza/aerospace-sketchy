#!/bin/bash
# Aerospace + Sketchybar Neustart (EMPFOHLENE METHODE - brew services)

# Zeige Benachrichtigung
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Aerospace Neustart"'

# Force Kill Aerospace
pkill -9 AeroSpace 2>/dev/null

# EMPFOHLENE METHODE: brew services restart sketchybar
# (verhindert Lock-File-Konflikte und Zombie-Prozesse)
killall -9 sketchybar lua 2>/dev/null

# Warte auf sauberes Beenden
sleep 2

# Starte Sketchybar via brew services (EMPFOHLEN)
brew services restart sketchybar

# Starte Aerospace neu
sleep 1
open -a AeroSpace

# Warte auf vollständigen Start
sleep 3

# Bestätigung
osascript -e 'display notification "Aerospace + Sketchybar Neustart abgeschlossen!" with title "Aerospace Neustart"'