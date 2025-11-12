#!/bin/bash
# Set current workspace to tiles horizontal (split vertical)

set -e
WORKSPACE=$(aerospace list-workspaces --focused)
STATE_FILE="/tmp/aerospace-layout-state-${WORKSPACE}"

if [ -f "$STATE_FILE" ] && grep -qx "h_tiles" "$STATE_FILE"; then
  echo "[Layout] Workspace $WORKSPACE already in Tiles Horizontal"
  exit 0
fi

aerospace layout tiles vertical horizontal
echo "h_tiles" > "$STATE_FILE"
echo "[Layout] Workspace $WORKSPACE → Tiles Horizontal (Hyper+H)"
