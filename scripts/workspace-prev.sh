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

# If not QWERTZ, check if numeric
if [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
  # Get all numeric workspaces, sorted
  NUMERIC_WS=($(aerospace list-workspaces --all | grep -E '^[0-9]+$' | sort -n))

  # Find current index
  for i in "${!NUMERIC_WS[@]}"; do
    if [[ "${NUMERIC_WS[$i]}" == "$CURRENT" ]]; then
      PREV_INDEX=$(( (i - 1 + ${#NUMERIC_WS[@]}) % ${#NUMERIC_WS[@]} ))
      PREV="${NUMERIC_WS[$PREV_INDEX]}"

      # If we're at first numeric and going back, go to last QWERTZ (G)
      if [[ $i -eq 0 ]]; then
        PREV="G"
      fi

      aerospace workspace "$PREV"
      exit 0
    fi
  done
fi

# Fallback: go to G (last QWERTZ)
aerospace workspace G
