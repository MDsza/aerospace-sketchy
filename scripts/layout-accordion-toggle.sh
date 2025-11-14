#!/bin/bash
# Toggle between Accordion horizontal und zuvor aktivem Layout

set -e
WORKSPACE=$(aerospace list-workspaces --focused)
STATE_FILE="/tmp/aerospace-layout-state-${WORKSPACE}"

CURRENT_STATE="h_tiles"
if [ -f "$STATE_FILE" ]; then
  CURRENT_STATE=$(cat "$STATE_FILE")
fi

LAST_NON_ACCORDION_FILE="/tmp/aerospace-last-non-accordion-${WORKSPACE}"

if [ "$CURRENT_STATE" = "h_accordion" ]; then
  if [ -f "$LAST_NON_ACCORDION_FILE" ]; then
    TARGET=$(cat "$LAST_NON_ACCORDION_FILE")
  else
    TARGET="h_tiles"
  fi
  case "$TARGET" in
    "h_tiles")
      aerospace layout tiles horizontal vertical
      ;;
    "v_tiles")
      aerospace layout tiles vertical horizontal
      ;;
    *)
      aerospace layout tiles horizontal vertical
      TARGET="h_tiles"
      ;;
  esac
  echo "$TARGET" > "$STATE_FILE"
  echo "[Layout] Workspace $WORKSPACE → Back to $TARGET"
else
  echo "$CURRENT_STATE" > "$LAST_NON_ACCORDION_FILE"
  aerospace layout accordion horizontal vertical
  echo "h_accordion" > "$STATE_FILE"
  echo "[Layout] Workspace $WORKSPACE → Accordion Horizontal (Hyper+Comma)"
fi
