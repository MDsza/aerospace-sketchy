#!/bin/bash
# focus-circular.sh
# Circular window focus navigation (wrap-around at edges)
# Usage: focus-circular.sh [left|right]

set -euo pipefail

DIRECTION="${1:-right}"

# Get current workspace
WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null || echo "")
if [ -z "$WORKSPACE" ]; then
  exit 0
fi

# Get all window IDs in current workspace (in order)
# NOTE: Using while-read loop instead of mapfile (Bash 3.2 compatible)
WINDOW_IDS=()
while IFS= read -r id; do
  WINDOW_IDS+=("$id")
done < <(aerospace list-windows --workspace "$WORKSPACE" --format '%{window-id}' 2>/dev/null)

TOTAL=${#WINDOW_IDS[@]}

# Need at least 2 windows for circular navigation
if [ "$TOTAL" -lt 2 ]; then
  exit 0
fi

# Get currently focused window ID
FOCUSED_ID=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | head -1)

if [ -z "$FOCUSED_ID" ]; then
  # No focused window, focus first
  aerospace focus --window-id "${WINDOW_IDS[0]}"
  /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh
  exit 0
fi

# Find index of focused window
CURRENT_INDEX=-1
for i in "${!WINDOW_IDS[@]}"; do
  if [ "${WINDOW_IDS[$i]}" = "$FOCUSED_ID" ]; then
    CURRENT_INDEX=$i
    break
  fi
done

if [ "$CURRENT_INDEX" -eq -1 ]; then
  # Focused window not found in list, focus first
  aerospace focus --window-id "${WINDOW_IDS[0]}"
  /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh
  exit 0
fi

# Calculate next index with wrap-around
if [ "$DIRECTION" = "right" ]; then
  NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL ))
else
  NEXT_INDEX=$(( (CURRENT_INDEX - 1 + TOTAL) % TOTAL ))
fi

# Focus next window
NEXT_ID="${WINDOW_IDS[$NEXT_INDEX]}"
aerospace focus --window-id "$NEXT_ID"

# Center mouse on newly focused window
/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh
