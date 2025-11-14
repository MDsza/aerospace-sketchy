#!/bin/bash
# Move window to workspace and trigger Sketchybar refresh
# Usage: move-to-workspace.sh Q|W|E|R|T|A|S|D|F|G
# Hyper+Cmd+Q/W/E/R/T/A/S/D/F/G

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <workspace>"
  exit 1
fi

WORKSPACE="$1"

# Move window to workspace
aerospace move-node-to-workspace "$WORKSPACE"

# Trigger Sketchybar icon refresh (Handler has 150ms delay built-in)
sketchybar --trigger workspace_force_refresh

echo "[move-to-workspace] Window → $WORKSPACE, Sketchybar refreshed" >&2  # stderr für debugging
