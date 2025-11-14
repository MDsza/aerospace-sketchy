#!/bin/bash
# workspace-prev.sh
# Navigate to previous OCCUPIED workspace in MONITOR-GROUPED order (matches Sketchybar visual order)

set -e

# Get current workspace
CURRENT=$(aerospace list-workspaces --focused 2>/dev/null || echo "G")

# Build monitor-grouped workspace order (same logic as Sketchybar)
# Get workspace-monitor mapping
WS_MONITOR=$(aerospace list-workspaces --all --format "%{workspace}|%{monitor-id}" 2>/dev/null)

# Get monitor info
MONITORS=$(aerospace list-monitors 2>/dev/null | awk '{print $1}')

# Detect Built-in monitor
BUILTIN_MON=""
for mon_id in $MONITORS; do
  mon_name=$(aerospace list-monitors 2>/dev/null | grep "^$mon_id" | cut -d'|' -f2-)
  if echo "$mon_name" | grep -qi "built-in"; then
    BUILTIN_MON=$mon_id
    break
  fi
done

# Fallback: highest ID is usually Built-in
[[ -z "$BUILTIN_MON" ]] && BUILTIN_MON=$(echo "$MONITORS" | sort -nr | head -1)

# QWERTZ sort function
qwertz_sort_key() {
  case $1 in
    Q) echo "01" ;; W) echo "02" ;; E) echo "03" ;; R) echo "04" ;; T) echo "05" ;;
    A) echo "06" ;; S) echo "07" ;; D) echo "08" ;; F) echo "09" ;; G) echo "10" ;;
    X) echo "11" ;; Y) echo "12" ;; Z) echo "13" ;;
    *) echo "99" ;;
  esac
}

# Group workspaces by monitor
BUILTIN_WS=""
EXTERNAL_WS=""

while IFS='|' read -r ws mon; do
  [[ -z "$ws" ]] && continue
  [[ ! "$ws" =~ ^[QWERTASDFGXYZ]$ ]] && continue

  if [[ "$mon" == "$BUILTIN_MON" ]]; then
    BUILTIN_WS="$BUILTIN_WS $ws"
  else
    EXTERNAL_WS="$EXTERNAL_WS $ws"
  fi
done <<< "$WS_MONITOR"

# Sort each group by QWERTZ order
sort_qwertz() {
  echo "$1" | tr ' ' '\n' | grep -v '^$' | while read -r ws; do
    echo "$(qwertz_sort_key "$ws") $ws"
  done | sort -n | awk '{print $2}'
}

BUILTIN_SORTED=$(sort_qwertz "$BUILTIN_WS")
EXTERNAL_SORTED=$(sort_qwertz "$EXTERNAL_WS")

# Build flat ordered list (Built-in first, then External)
ORDERED_WS=$(echo -e "$BUILTIN_SORTED\n$EXTERNAL_SORTED" | grep -v '^$')

# Get occupied workspaces
OCCUPIED=$(aerospace list-windows --all --format "%{workspace}" 2>/dev/null | \
           grep -E '^[QWERTASDFGXYZ]$' | sort -u)

# Filter ordered list to only occupied
OCCUPIED_ORDERED=""
while read -r ws; do
  if echo "$OCCUPIED" | grep -q "^$ws$"; then
    OCCUPIED_ORDERED="$OCCUPIED_ORDERED $ws"
  fi
done <<< "$ORDERED_WS"

# Convert to array
OCCUPIED_ARRAY=($OCCUPIED_ORDERED)

# Find current index
CURRENT_INDEX=-1
for i in "${!OCCUPIED_ARRAY[@]}"; do
  if [[ "${OCCUPIED_ARRAY[$i]}" == "$CURRENT" ]]; then
    CURRENT_INDEX=$i
    break
  fi
done

# Find previous (wrap-around)
if [[ $CURRENT_INDEX -ge 0 ]]; then
  PREV_INDEX=$(( (CURRENT_INDEX - 1 + ${#OCCUPIED_ARRAY[@]}) % ${#OCCUPIED_ARRAY[@]} ))
  PREV="${OCCUPIED_ARRAY[$PREV_INDEX]}"
else
  # Fallback: last occupied
  PREV="${OCCUPIED_ARRAY[-1]}"
fi

# Fallback if no occupied workspaces
[[ -z "$PREV" ]] && PREV="G"

# Switch workspace + center mouse
aerospace workspace "$PREV"
/Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/center-mouse.sh 2>/dev/null || true
