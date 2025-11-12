#!/bin/bash
# Apple-Logo Doppelklick Handler → Sanfter Refresh (kein Kill)

PROJECT_ROOT="/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy"
REFRESH_SCRIPT="$PROJECT_ROOT/scripts/refresh-aerospace-sketchy.sh"

if [ ! -x "$REFRESH_SCRIPT" ]; then
  osascript -e 'display notification "Refresh-Script nicht gefunden!" with title "Apple-Logo"' >/dev/null 2>&1 || true
  exit 1
fi

"$REFRESH_SCRIPT" &
exit 0
