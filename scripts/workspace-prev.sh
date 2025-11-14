#!/bin/bash
# workspace-prev.sh
# Navigate to previous OCCUPIED workspace in QWERTZ layout order

set -e

# QWERTZ layout order (left to right, top to bottom)
QWERTZ_ORDER=(Q W E R T A S D F G)

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null || echo "G")

# Get ALL occupied workspaces across ALL monitors (single cached query)
# Note: Includes workspaces on external monitor (intended - cycle all occupied)
OCCUPIED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | \
           grep -E '^[QWERTASDFG]$' | \
           sort -u | \
           tr '\n' ' ')

# Find current index in QWERTZ_ORDER
CURRENT_INDEX=-1
for i in "${!QWERTZ_ORDER[@]}"; do
  if [[ "${QWERTZ_ORDER[$i]}" == "$CURRENT" ]]; then
    CURRENT_INDEX=$i
    break
  fi
done

# Fallback if current not in array
[[ $CURRENT_INDEX -eq -1 ]] && CURRENT_INDEX=9  # G is last (index 9)

# Find previous occupied workspace (wrap-around)
PREV=""
for ((i=1; i<=${#QWERTZ_ORDER[@]}; i++)); do
  idx=$(( (CURRENT_INDEX - i + ${#QWERTZ_ORDER[@]}) % ${#QWERTZ_ORDER[@]} ))
  candidate="${QWERTZ_ORDER[$idx]}"

  # Check if candidate is occupied (word boundary match)
  if echo " $OCCUPIED " | grep -q " $candidate "; then
    PREV="$candidate"
    break
  fi
done

# Fallback if ALL empty: go to G
[[ -z "$PREV" ]] && PREV="G"

# Switch workspace + center mouse
aerospace workspace "$PREV"
/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh 2>/dev/null || true
