#!/bin/bash
# focus-monitor-and-center.sh
# Focus monitor in direction and center mouse on focused window
# Usage: focus-monitor-and-center.sh [prev|next]

set -e

DIRECTION="$1"

if [ -z "$DIRECTION" ]; then
  echo "Usage: $0 [prev|next]"
  exit 1
fi

# Focus monitor in direction
aerospace focus-monitor --wrap-around "$DIRECTION"

# Small delay to let Aerospace update focus
sleep 0.05

# Center mouse on newly focused window
/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh
