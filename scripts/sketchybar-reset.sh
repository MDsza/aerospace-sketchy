#!/usr/bin/env bash

set -e  # Exit on any error

# SketchyBar Reset Script v3.0.0 (Aerospace)
#
# Purpose: Fixes SketchyBar display issues
# Usage: ./sketchybar-reset.sh
#
# - Kills and restarts SketchyBar with proper timing
# - Reloads configuration
# - Triggers Aerospace workspace refresh
#
# Author: Wolfgang (aerospace+sketchy Setup)
# Version: 3.0.0 (December 2025)

echo "=== SketchyBar Reset v3.0.0 (Aerospace) ==="

# SketchyBar neustarten
echo "1. SketchyBar wird neugestartet..."
brew services restart sketchybar
sleep 3

# Konfiguration neu laden
echo "2. Konfiguration wird neu geladen..."
sketchybar --reload

# Aerospace Workspace-Refresh triggern
echo "3. Aerospace Workspace-Status wird aktualisiert..."
FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null || echo "Q")
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED" 2>/dev/null || true

echo "=== Reset abgeschlossen ==="
echo "Workspace-Icons sollten jetzt korrekt angezeigt werden."
