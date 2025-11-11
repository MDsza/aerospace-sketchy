#!/bin/bash

# Aerospace Layout Toggle Script
# Cycles through: tiles horizontal → tiles vertical → accordion horizontal → accordion vertical → floating
# Author: Claude Code (Aerospace Migration)
# Version: 1.0

set -e

# State file to track current layout
WORKSPACE=$(aerospace list-workspaces --focused)
STATE_FILE="/tmp/aerospace-layout-state-${WORKSPACE}"

# Read current state (default: tiles horizontal)
CURRENT_STATE="h_tiles"
if [ -f "$STATE_FILE" ]; then
    CURRENT_STATE=$(cat "$STATE_FILE")
fi

echo "[Aerospace Layout Toggle] Workspace $WORKSPACE: Current state: $CURRENT_STATE"

# Cycle through layouts
case "$CURRENT_STATE" in
    "h_tiles")
        aerospace layout v_tiles
        echo "v_tiles" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Switched to Tiles Vertical"
        ;;
    "v_tiles")
        aerospace layout h_accordion
        echo "h_accordion" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Switched to Accordion Horizontal"
        ;;
    "h_accordion")
        aerospace layout v_accordion
        echo "v_accordion" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Switched to Accordion Vertical"
        ;;
    "v_accordion")
        aerospace layout floating
        echo "floating" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Switched to Floating"
        ;;
    "floating")
        aerospace layout h_tiles
        echo "h_tiles" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Switched to Tiles Horizontal"
        ;;
    *)
        # Unknown state - reset to default
        aerospace layout h_tiles
        echo "h_tiles" > "$STATE_FILE"
        echo "[Aerospace Layout Toggle] ✅ Reset to Tiles Horizontal"
        ;;
esac

# Log action for debugging
echo "$(date '+%Y-%m-%d %H:%M:%S') - Workspace $WORKSPACE: $(cat $STATE_FILE)" >> /tmp/aerospace-layout-toggle.log
