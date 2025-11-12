#!/bin/bash
# focus-and-center.sh
# Focus window in direction and center mouse
# Usage: focus-and-center.sh [left|right|up|down]

set -e

DIRECTION="$1"

if [ -z "$DIRECTION" ]; then
  echo "Usage: $0 [left|right|up|down]"
  exit 1
fi

# Focus window in direction
aerospace focus "$DIRECTION"

# Center mouse on newly focused window
/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh
