#!/bin/bash
# Check if Claude Code is waiting for input
# Called periodically by SketchyBar widget

FLAG_FILE="/tmp/claude-waiting-flag"

if [ -f "$FLAG_FILE" ]; then
  # Claude is waiting - show widget with pulsing animation
  sketchybar --set "$NAME" drawing=on \
             --animate sin 30 --set "$NAME" icon.color.alpha=0.3 icon.color.alpha=1.0
else
  # Claude is not waiting - hide widget
  sketchybar --set "$NAME" drawing=off icon.color.alpha=1.0
fi
