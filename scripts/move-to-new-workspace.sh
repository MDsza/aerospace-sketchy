#!/bin/bash
# move-to-new-workspace.sh
# Aerospace equivalent of Yabai's window-move-to-new-space-maximize.sh
#
# Finds next available workspace number and moves current window there
# Optionally maximizes the window (fullscreen)

set -e

# Get all existing workspaces
EXISTING_WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null | tr '\n' ' ')

# Find next available numeric workspace
# Start from 11 (1-10 are typically used, plus letter workspaces)
NEXT_WORKSPACE=11

while echo "$EXISTING_WORKSPACES" | grep -q "\<$NEXT_WORKSPACE\>"; do
    NEXT_WORKSPACE=$((NEXT_WORKSPACE + 1))
done

echo "Moving window to new workspace: $NEXT_WORKSPACE"

# Move current window to new workspace
aerospace move-node-to-workspace "$NEXT_WORKSPACE"

# Switch to the new workspace
aerospace workspace "$NEXT_WORKSPACE"

# Optional: Fullscreen the window (like Yabai maximize)
# Uncomment if you want automatic fullscreen
# sleep 0.2
# aerospace fullscreen on

# Trigger Sketchybar update (new workspace will be auto-discovered)
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$NEXT_WORKSPACE" 2>/dev/null || true

echo "Window moved to workspace $NEXT_WORKSPACE"
