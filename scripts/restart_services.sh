#!/bin/bash
# Aerospace + Sketchybar Neustart - DEAKTIVIERT
# Zu instabil für automatischen Restart via Apple-Logo

osascript -e 'display notification "Bitte Terminal öffnen und ausführen:\nkillall sketchybar && sketchybar" with title "Sketchybar Neustart"' &

exit 0
