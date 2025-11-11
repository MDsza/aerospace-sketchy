#!/bin/bash
# Speichere als ~/.config/sketchybar/plugins/apple_click_handler.sh

# Debug-Ausgabe in Log-Datei
exec 2>>/tmp/sketchybar_apple_handler.log
echo "$(date): Script ausgeführt" >>/tmp/sketchybar_apple_handler.log

# Definiere absolute Pfade
CONFIG_DIR="$HOME/.config/sketchybar"
RESTART_SCRIPT="$CONFIG_DIR/plugins/restart_services.sh"
MENU_SCRIPT="$CONFIG_DIR/helpers/menus/bin/menus"
TEMP_FILE="/tmp/apple_click_count"

# Lese aktuelle Klick-Zählung
COUNT=$(cat "$TEMP_FILE" 2>/dev/null || echo "0")
echo "Aktuelle Klick-Zählung: $COUNT" >>/tmp/sketchybar_apple_handler.log

# Erhöhe Zählung
COUNT=$((COUNT+1))
echo "$COUNT" > "$TEMP_FILE"

# Prüfe auf Doppelklick
if [ "$COUNT" -eq 2 ]; then
  # Doppelklick erkannt, führe Neustart aus
  echo "Doppelklick erkannt, starte Neustart-Skript" >>/tmp/sketchybar_apple_handler.log
  
  if [ -x "$RESTART_SCRIPT" ]; then
    "$RESTART_SCRIPT"
  else
    echo "FEHLER: Neustart-Skript nicht ausführbar: $RESTART_SCRIPT" >>/tmp/sketchybar_apple_handler.log
    # Fallback: Direkt neustarten (Aerospace)
    killall AeroSpace 2>/dev/null && sleep 1 && open -a AeroSpace
    sleep 1
    killall sketchybar 2>/dev/null && sleep 1 && sketchybar
  fi
  
  # Setze Zählung zurück
  echo "0" > "$TEMP_FILE"
else
  # Erster Klick, führe das originale Skript aus
  echo "Erster Klick, führe originales Menü-Skript aus" >>/tmp/sketchybar_apple_handler.log
  
  if [ -x "$MENU_SCRIPT" ]; then
    "$MENU_SCRIPT" -s 0
  else
    echo "FEHLER: Menü-Skript nicht gefunden oder nicht ausführbar: $MENU_SCRIPT" >>/tmp/sketchybar_apple_handler.log
  fi
  
  # Starte Timer zum Zurücksetzen
  (sleep 0.5 && echo "0" > "$TEMP_FILE") &
fi