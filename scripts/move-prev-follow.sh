#!/bin/bash
# move-prev-follow.sh
# Move window to previous workspace in QWERTZ order and follow

set -e

# QWERTZ layout order (left to right, top to bottom)
QWERTZ_ORDER=(Q W E R T A S D F G)

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null)

# Check if current is QWERTZ workspace
for i in "${!QWERTZ_ORDER[@]}"; do
  if [[ "${QWERTZ_ORDER[$i]}" == "$CURRENT" ]]; then
    # Found current in QWERTZ order, get prev
    PREV_INDEX=$(( (i - 1 + ${#QWERTZ_ORDER[@]}) % ${#QWERTZ_ORDER[@]} ))
    PREV="${QWERTZ_ORDER[$PREV_INDEX]}"

    # Move and follow
    aerospace move-node-to-workspace "$PREV"
    aerospace workspace "$PREV"
    exit 0
  fi
done

# Fallback: move to G (last QWERTZ) and follow
aerospace move-node-to-workspace G
aerospace workspace G
