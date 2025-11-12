#!/bin/bash
# Set current workspace to tiles vertical (split horizontal)

set -e
WORKSPACE=$(aerospace list-workspaces --focused)
STATE_FILE="/tmp/aerospace-layout-state-${WORKSPACE}"

if [ -f "$STATE_FILE" ] && grep -qx "v_tiles" "$STATE_FILE"; then
  echo "[Layout] Workspace $WORKSPACE already in Tiles Vertical"
  exit 0
fi

aerospace layout tiles horizontal vertical
echo "v_tiles" > "$STATE_FILE"
echo "[Layout] Workspace $WORKSPACE → Tiles Vertical (Hyper+V)"
