#!/bin/bash
# workspace-prev.sh
# Navigate to previous workspace in QWERTZ layout order

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
    aerospace workspace "$PREV"
    exit 0
  fi
done

# Fallback: always jump to last QWERTZ workspace
aerospace workspace G
