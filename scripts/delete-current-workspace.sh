#!/bin/bash
# delete-current-workspace.sh
# Aerospace equivalent of Yabai's delete-empty-spaces.sh
#
# Closes all windows on current workspace and switches away
# Empty workspaces will be hidden by Sketchybar filter (soft-delete)

set -e

# Get current workspace
CURRENT_WS=$(aerospace list-workspaces --focused 2>/dev/null)

if [ -z "$CURRENT_WS" ]; then
  echo "Error: Could not determine current workspace"
  exit 1
fi

# Protect QWERTZ workspaces (Q W E R T A S D F G) from deletion
if [[ "$CURRENT_WS" =~ ^[QWERTASDFG]$ ]]; then
  echo "Cannot delete protected QWERTZ workspace: $CURRENT_WS"
  osascript -e 'display notification "Cannot delete QWERTZ workspace '$CURRENT_WS'" with title "Aerospace"'
  exit 1
fi

echo "Closing all windows on workspace: $CURRENT_WS"

# Count windows before deletion
WINDOW_COUNT=$(aerospace list-windows --workspace "$CURRENT_WS" 2>/dev/null | wc -l | tr -d ' ')

if [ "$WINDOW_COUNT" -eq 0 ]; then
  echo "Workspace $CURRENT_WS is already empty"
  # Switch to workspace 1 anyway
  aerospace workspace 1
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=1 2>/dev/null || true
  exit 0
fi

# Close all windows except current
aerospace close-all-windows-but-current 2>/dev/null || true
sleep 0.2

# Close the last window (current)
aerospace close 2>/dev/null || true
sleep 0.2

# Switch to workspace 1 (or first available letter workspace)
echo "Switching to workspace 1"
aerospace workspace 1

# Trigger Sketchybar refresh
# The empty workspace filter will hide workspace $CURRENT_WS
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=1 2>/dev/null || true

echo "Workspace $CURRENT_WS deleted (closed $WINDOW_COUNT windows)"
echo "Empty workspaces are now hidden in Sketchybar"
