#!/bin/bash
# move-next-follow.sh
# Move window to next workspace in QWERTZ order and follow

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

    # Move and follow
    aerospace move-node-to-workspace "$NEXT"
    aerospace workspace "$NEXT"
    exit 0
  fi
done

# If not QWERTZ, check if numeric
if [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
  # Get all numeric workspaces, sorted
  NUMERIC_WS=($(aerospace list-workspaces --all | grep -E '^[0-9]+$' | sort -n))

  # Find current index
  for i in "${!NUMERIC_WS[@]}"; do
    if [[ "${NUMERIC_WS[$i]}" == "$CURRENT" ]]; then
      NEXT_INDEX=$(( (i + 1) % ${#NUMERIC_WS[@]} ))
      NEXT="${NUMERIC_WS[$NEXT_INDEX]}"

      # If we wrapped around, go to first QWERTZ workspace
      if [[ $NEXT_INDEX -eq 0 ]]; then
        NEXT="Q"
      fi

      # Move and follow
      aerospace move-node-to-workspace "$NEXT"
      aerospace workspace "$NEXT"
      exit 0
    fi
  done
fi

# Fallback: move to Q and follow
aerospace move-node-to-workspace Q
aerospace workspace Q
