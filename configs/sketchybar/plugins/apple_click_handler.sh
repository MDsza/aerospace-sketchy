#!/bin/bash
# Apple-Logo Klick Handler → Toggle AeroSpace aktiv/pausiert

PROJECT_ROOT="/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy"
REFRESH_SCRIPT="$PROJECT_ROOT/scripts/refresh-aerospace-sketchy.sh"
STATE_FILE="/tmp/aerospace-paused-state"

# Wenn State-File existiert → AeroSpace läuft NICHT → reaktivieren
if [ -f "$STATE_FILE" ]; then
    # Reaktivieren
    # TODO Aerospace v0.20+: 'enable' → 'managed' (Breaking Change!)
    aerospace enable on
    sleep 0.3

    # Borders restart (nur wenn vorhanden)
    killall borders 2>/dev/null || true
    if [ -x "$PROJECT_ROOT/scripts/start-borders.sh" ]; then
        "$PROJECT_ROOT/scripts/start-borders.sh" &
    fi

    # Soft-Refresh ausführen
    if [ -x "$REFRESH_SCRIPT" ]; then
        "$REFRESH_SCRIPT" &
    fi

    # State-File löschen
    rm -f "$STATE_FILE"

    # Notification
    osascript -e 'display notification "▶️ AeroSpace Active" with title "AeroSpace"' >/dev/null 2>&1 || true

    # Icon weiß
    sketchybar --set apple icon.color=0xffffffff
else
    # Pausieren
    # TODO Aerospace v0.20+: 'enable' → 'managed' (Breaking Change!)
    aerospace enable off

    # Borders stoppen
    killall borders 2>/dev/null || true

    # State-File schreiben
    touch "$STATE_FILE"

    # Notification
    osascript -e 'display notification "⏸️ AeroSpace Paused" with title "AeroSpace"' >/dev/null 2>&1 || true

    # Icon dunkelgrau
    sketchybar --set apple icon.color=0xff6e6e6e
fi

exit 0
