#!/bin/bash
# Aerospace + Sketchybar Neustart (FUNKTIONIERENDE METHODE - Direkter Start)

# Zeige Benachrichtigung
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Aerospace Neustart"' &

# 1. Stoppe Services (falls läuft)
brew services stop sketchybar 2>/dev/null

# 2. Force Kill ALLES
pkill -9 AeroSpace 2>/dev/null
killall -9 sketchybar 2>/dev/null
killall -9 lua 2>/dev/null
pkill -9 -f "sketchybar" 2>/dev/null

# 3. Remove Lock-Files
rm -f /tmp/sketchybar_wolfgang.lock 2>/dev/null

# 4. Warte bis WIRKLICH alles gestoppt (max 5 Sekunden)
for i in {1..10}; do
  PROCS=$(ps aux | grep -E '[s]ketchybar|[l]ua.*sketchybar' | wc -l)
  if [ "$PROCS" -eq 0 ]; then
    break
  fi
  sleep 0.5
done

# 5. Starte Sketchybar DIREKT (NICHT via brew services!)
# WICHTIG: KEIN Redirect (> /dev/null), sonst lädt spaces.lua nicht!
sketchybar &

# 6. Warte bis Sketchybar WIRKLICH läuft UND Workspaces geladen (max 10 Sekunden)
for i in {1..20}; do
  WORKSPACES=$(sketchybar --query bar 2>/dev/null | grep "space\." | wc -l | tr -d ' ')
  if [ -n "$WORKSPACES" ] && [ "$WORKSPACES" -gt 10 ] 2>/dev/null; then
    break
  fi
  sleep 0.5
done

# 7. Starte Aerospace neu
open -a AeroSpace

# 8. Warte kurz
sleep 1

# 9. Bestätigung
osascript -e 'display notification "Aerospace + Sketchybar Neustart abgeschlossen!" with title "Aerospace Neustart"' &