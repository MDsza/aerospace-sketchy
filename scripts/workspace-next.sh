#!/bin/bash
# workspace-next.sh
# Navigate to next workspace in QWERTZ layout order

set -e

# QWERTZ layout order (left to right, top to bottom)
QWERTZ_ORDER=(Q W E R T A S D F G)

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null)

# Check if current is QWERTZ workspace
for i in "${!QWERTZ_ORDER[@]}"; do
  if [[ "${QWERTZ_ORDER[$i]}" == "$CURRENT" ]]; then
    # Found current in QWERTZ order, get next
    NEXT_INDEX=$(( (i + 1) % ${#QWERTZ_ORDER[@]} ))
    NEXT="${QWERTZ_ORDER[$NEXT_INDEX]}"
    aerospace workspace "$NEXT"
    exit 0
  fi
done

# Fallback: Always go back to Q
aerospace workspace Q
