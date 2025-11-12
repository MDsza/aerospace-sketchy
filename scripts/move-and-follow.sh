#!/bin/bash
# move-and-follow.sh
# Move focused window to workspace and follow (like Yabai)
# Usage: move-and-follow.sh WORKSPACE_NAME

set -e

WORKSPACE="$1"

if [ -z "$WORKSPACE" ]; then
  echo "Error: No workspace specified"
  exit 1
fi

# Move window to workspace
aerospace move-node-to-workspace "$WORKSPACE"

# Follow to the workspace
aerospace workspace "$WORKSPACE"
