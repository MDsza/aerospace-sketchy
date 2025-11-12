#!/bin/bash
# Sanfter Refresh für Aerospace + Sketchybar (kein Prozess-Kill)
# Ziel: Configs neu einlesen, Events triggern, Darstellung reparieren

set -euo pipefail

PROJECT_ROOT="/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy"
VERIFY_SCRIPT="$PROJECT_ROOT/scripts/verify-symlinks.sh"

notify() {
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1 || true
}

log_info() {
  echo "[refresh] $*"
}

# 1) Symlink-Check (damit garantiert nur eine Config existiert)
if [ -x "$VERIFY_SCRIPT" ]; then
  if ! "$VERIFY_SCRIPT" >/tmp/refresh_symlink_check.log 2>&1; then
    notify "Refresh fehlgeschlagen" "Symlink-Check fehlgeschlagen – siehe /tmp/refresh_symlink_check.log"
    exit 1
  fi
else
  log_info "WARN: verify-symlinks.sh nicht ausführbar – bitte prüfen!"
fi

notify "Refresh" "Config wird neu geladen…"

# 2) Aktuellen Workspace und App merken
CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null | head -1 | tr -d '[:space:]')
if [ -z "$CURRENT_WS" ]; then
  CURRENT_WS="Q"
fi

CURRENT_APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1 | sed -e 's/^ *//' -e 's/ *$//')
[ -n "$CURRENT_APP" ] || CURRENT_APP="—"

# 3) Aerospace Config neu einlesen
log_info "Reloading Aerospace config…"
aerospace reload-config >/tmp/aerospace_refresh.log 2>&1 || {
  notify "Refresh fehlgeschlagen" "aerospace reload-config konnte nicht ausgeführt werden"
  exit 1
}

sleep 0.5

# Fokus zurück auf vorherigen Workspace (sorgt für Events)
aerospace workspace "$CURRENT_WS" >/dev/null 2>&1 || true

# 4) Borders optional erneut starten (falls Script existiert)
if [ -x "$PROJECT_ROOT/scripts/start-borders.sh" ]; then
  "$PROJECT_ROOT/scripts/start-borders.sh" >/tmp/borders_refresh.log 2>&1 || true
fi

# 5) Sketchybar sanft neu laden & Events triggern
log_info "Reloading Sketchybar…"
sketchybar --reload >/tmp/sketchybar_reload.log 2>&1 || true

sleep 0.5
sketchybar --trigger aerospace_workspace_change "FOCUSED_WORKSPACE=$CURRENT_WS" >/dev/null 2>&1 || true
sketchybar --trigger front_app_switched "INFO=$CURRENT_APP" >/dev/null 2>&1 || true
sleep 0.5
sketchybar --trigger workspace_force_refresh >/dev/null 2>&1 || true

notify "Refresh erfolgreich" "Workspace $CURRENT_WS, App $CURRENT_APP"
exit 0
