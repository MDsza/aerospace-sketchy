#!/bin/bash
# Toggle between tiles horizontal and tiles vertical layouts
# Hyper+B

set -e
WORKSPACE=$(aerospace list-workspaces --focused)
STATE_FILE="/tmp/aerospace-layout-state-${WORKSPACE}"

# Read current state (default to h_tiles if file doesn't exist)
if [ -f "$STATE_FILE" ]; then
  CURRENT_STATE=$(cat "$STATE_FILE")
else
  CURRENT_STATE="h_tiles"  # Default assumption
fi

# Toggle to opposite layout
if [ "$CURRENT_STATE" = "h_tiles" ]; then
  # Switch to Vertical (split horizontal)
  aerospace layout tiles horizontal vertical
  echo "v_tiles" > "$STATE_FILE"
  echo "[Layout-Toggle] Workspace $WORKSPACE → Tiles Vertical (Hyper+B)"
else
  # Switch to Horizontal (split vertical)
  aerospace layout tiles vertical horizontal
  echo "h_tiles" > "$STATE_FILE"
  echo "[Layout-Toggle] Workspace $WORKSPACE → Tiles Horizontal (Hyper+B)"
fi
