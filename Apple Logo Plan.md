Bitte implementiere folgenden Plan, ohne davon abzuweichen:

Ziel
- Ein einzelner Klick auf das Apple-Logo in Sketchybar toggelt AeroSpace zwischen „aktiv“ und „pausiert“.
- Beim Pausieren stoppt das Window-Management komplett; beim Reaktivieren wird sofort unser bestehender Soft-Refresh ausgeführt.
- Das Apple-Icon zeigt den Zustand farblich an (weiß = aktiv, dunkelgrau = pausiert).

Implementierungsschritte

1. apple_click_handler.sh (Pfad: ~/.config/sketchybar/plugins/apple_click_handler.sh)
   - Neues State-File: /tmp/aerospace-paused-state
   - **WICHTIG - Aerospace-Befehl (versionsabhängig):**
     - **Aerospace ≤ 0.19.x**: `aerospace enable on/off` ← **AKTUELL IN VERWENDUNG (v0.19.2-Beta)**
     - **Aerospace ≥ 0.20**: `aerospace managed on/off` ← Bei Upgrade umstellen!
   - Wenn das State-File existiert → AeroSpace läuft NICHT:
       * `aerospace enable on` (bzw. `managed on` ab v0.20)
       * kurze Wartezeit (~0.3 s)
       * `killall borders` (falls läuft), danach `scripts/start-borders.sh` (nur wenn vorhanden) im Hintergrund neu starten
       * `scripts/refresh-aerospace-sketchy.sh` im Hintergrund ausführen
       * State-File löschen
       * Notification: „▶️ AeroSpace Active“
       * `sketchybar --set apple icon= icon.color=0xffffffff`
   - Wenn das State-File NICHT existiert → AeroSpace läuft:
       * `aerospace enable off` (bzw. `managed off` ab v0.20)
       * `killall borders`
       * State-File schreiben
       * Notification: „⏸️ AeroSpace Paused“
       * `sketchybar --set apple icon= icon.color=0xff6e6e6e`
   - Skript am Ende mit Exit 0 verlassen.

2. scripts/refresh-aerospace-sketchy.sh
   - Beim Borders-Start (ca. Zeile 52) zusätzlich prüfen, ob das State-File NICHT vorhanden ist:
     ```
     if [ -x "$PROJECT_ROOT/scripts/start-borders.sh" ] && [ ! -f /tmp/aerospace-paused-state ]; then
         "$PROJECT_ROOT/scripts/start-borders.sh" >/tmp/borders_refresh.log 2>&1 || true
     fi
     ```

3. configs/sketchybar/items/apple.lua (optional, aber empfohlen)
   - Nach dem Item-Setup einen kleinen Sync einbauen: Bei `aerospace_workspace_change` prüfen, ob das State-File existiert, und die Icon-Farbe entsprechend setzen (weiß vs. dunkelgrau). So bleibt die Anzeige auch nach Sketchybar-Neustart korrekt.

Tests
- Klick 1: Icon wird grau, Notification „⏸️“, Hyper+H/V etc. reagieren nicht mehr, `/tmp/aerospace-paused-state` existiert.
- Klick 2: Icon wird weiß, Notification „▶️“, Hyper-Shortcuts greifen wieder, Borders läuft, State-File ist weg.
- Prüfen, dass `scripts/refresh-aerospace-sketchy.sh` im pausierten Zustand keine Borders startet.
- Sketchybar-Restart: Farbe bleibt entsprechend dem State-File.
- Reboot: /tmp wird geleert → AeroSpace startet aktiv (weißes Icon).

Bitte exakt in dieser Reihenfolge implementieren und am Ende kurz zusammenfassen, welche Dateien angepasst wurden und wie getestet wurde.
