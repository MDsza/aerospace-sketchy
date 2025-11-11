#!/usr/bin/env bash

# Dual SketchyBar Setup Script
# Startet beide SketchyBar Instanzen: Top (Status) + Bottom (Spaces)

echo "Starting Dual SketchyBar Setup..."

# Kill existing SketchyBar instances
killall sketchybar 2>/dev/null || true
sleep 1

# SketchyBar unterstützt nur eine Instanz - wir müssen die Items in einer Bar kombinieren
# Stattdessen konfigurieren wir eine einzige Bar mit Items oben UND unten

echo "Starting unified SketchyBar with top and bottom items..."
sketchybar --config ~/.config/sketchybar/init_dual.lua &
BAR_PID=$!

sleep 1

echo "Dual SketchyBar setup complete!"
echo "Bottom Bar PID: $BOTTOM_PID"
echo "Top Bar PID: $TOP_PID"

# Optional: Save PIDs for later management
echo "$BOTTOM_PID" > /tmp/sketchybar_bottom.pid
echo "$TOP_PID" > /tmp/sketchybar_top.pid