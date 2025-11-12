#!/bin/bash
# move-window-to-monitor.sh
# Smart window-to-monitor move with app-based workspace assignment

set -e

# Get all monitors
ALL_MONITORS=($(aerospace list-monitors | awk '{print $1}'))

if [ "${#ALL_MONITORS[@]}" -lt 2 ]; then
  exit 0
fi

# Get current monitor
CURRENT_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')

# Find target monitor (next, wrap around)
TARGET_MONITOR=""
for i in "${!ALL_MONITORS[@]}"; do
  if [[ "${ALL_MONITORS[$i]}" == "$CURRENT_MONITOR" ]]; then
    NEXT_INDEX=$(( (i + 1) % ${#ALL_MONITORS[@]} ))
    TARGET_MONITOR="${ALL_MONITORS[$NEXT_INDEX]}"
    break
  fi
done

# Check if target monitor has workspaces
WORKSPACES_ON_TARGET=$(aerospace list-workspaces --monitor "$TARGET_MONITOR" 2>/dev/null | head -1)

if [ -n "$WORKSPACES_ON_TARGET" ]; then
  # Target has workspaces - normal move
  aerospace move-node-to-monitor --wrap-around next
else
  # Target empty - intelligent workspace creation

  # Get app-id of focused window
  APP_ID=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null | head -1)

  # Map app-id to workspace (from .aerospace.toml assignments)
  TARGET_WORKSPACE=""

  case "$APP_ID" in
    md.obsidian) TARGET_WORKSPACE="Q" ;;
    com.citrix.receiver.nomas|com.citrix.XenAppViewer) TARGET_WORKSPACE="W" ;;
    com.microsoft.Outlook|com.apple.mail) TARGET_WORKSPACE="E" ;;
    com.microsoft.VSCode|com.anthropic.claude|com.openai.chat|com.todesktop.230313mzl4w4u92|org.jupyter.jupyterlab-desktop) TARGET_WORKSPACE="A" ;;
    com.apple.Safari|com.google.Chrome|org.mozilla.firefox|com.brave.Browser|company.thebrowser.Browser|company.thebrowser.arc) TARGET_WORKSPACE="S" ;;
    com.culturedcode.ThingsMac|com.omnigroup.OmniFocus3|com.todoist.mac.Todoist) TARGET_WORKSPACE="D" ;;
    com.apple.finder|com.binarynights.ForkLift-3|com.cocoatech.PathFinder|com.eltima.cmd1) TARGET_WORKSPACE="F" ;;
  esac

  if [ -n "$TARGET_WORKSPACE" ]; then
    # App has defined workspace - use it
    aerospace move-node-to-workspace "$TARGET_WORKSPACE"
    aerospace workspace "$TARGET_WORKSPACE"
    aerospace move-workspace-to-monitor "$TARGET_MONITOR"
  else
    # No app assignment - use overflow workspaces X/Y/Z
    # Determine which overflow workspace based on monitor index
    MONITOR_INDEX=0
    for i in "${!ALL_MONITORS[@]}"; do
      if [[ "${ALL_MONITORS[$i]}" == "$TARGET_MONITOR" ]]; then
        MONITOR_INDEX=$i
        break
      fi
    done

    # Assign X/Y/Z based on monitor index (skip builtin monitor = index 0)
    if [ "$MONITOR_INDEX" -eq 1 ]; then
      OVERFLOW_WS="X"
    elif [ "$MONITOR_INDEX" -eq 2 ]; then
      OVERFLOW_WS="Y"
    else
      OVERFLOW_WS="Z"
    fi

    # Move to overflow workspace and then to target monitor
    aerospace move-node-to-workspace "$OVERFLOW_WS"
    aerospace workspace "$OVERFLOW_WS"
    aerospace move-workspace-to-monitor "$TARGET_MONITOR"
  fi
fi
