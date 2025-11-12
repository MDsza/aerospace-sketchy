#!/bin/bash
# start-borders.sh
# Start JankyBorders with subtle orange theme

# Kill existing instance
killall borders 2>/dev/null

# Start borders
# Color format: 0xAARRGGBB (Alpha, Red, Green, Blue)
# Active: Subtle Orange (0xffD77A3D) - dezent & warm
# Inactive: Dark Gray (0xff2a2a2a)

borders \
  style=round \
  active_color=0xffD77A3D \
  inactive_color=0xff2a2a2a \
  width=5.0 \
  hidpi=on &

echo "JankyBorders started with subtle orange theme"
