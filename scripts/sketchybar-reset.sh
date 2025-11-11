#!/usr/bin/env bash

set -e  # Exit on any error

# SketchyBar Reset Script v2.3.0
#
# Purpose: Fixes SketchyBar display issues with many spaces
# Usage: ./sketchybar-reset.sh
#
# - Kills and restarts SketchyBar with proper timing
# - Reloads configuration
# - Triggers YabaiIndicator refresh
# - Fixes overlapping space icons
#
# Author: Wolfgang (yabai-skhd-sbar Setup)
# Version: 2.3.0 (September 2025)

echo "=== SketchyBar Reset v2.3.0 für viele Spaces ==="

# SketchyBar neustarten
echo "1. SketchyBar wird neugestartet..."
killall sketchybar 2>/dev/null || true
sleep 1
sketchybar &
sleep 2

# Konfiguration neu laden
echo "2. Konfiguration wird neu geladen..."
sketchybar --reload

echo "3. YabaiIndicator wird aktualisiert..."
echo "refresh" | nc -U /tmp/yabai-indicator.socket 2>/dev/null || true

echo "=== Reset abgeschlossen ==="
echo "Die Space-Icons sollten jetzt kompakter und ohne Überlappung angezeigt werden."
