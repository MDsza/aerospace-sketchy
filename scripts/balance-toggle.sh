#!/bin/bash

# Aerospace Balance Toggle Script
# Simplified version - Aerospace handles window management automatically
# Author: Claude Code (Aerospace Migration)
# Version: 1.0

set -e

# Get current workspace
WORKSPACE=$(aerospace list-workspaces --focused)

echo "[Aerospace Balance Toggle] Workspace $WORKSPACE: Balancing window sizes..."

# Balance all windows in current workspace
aerospace balance-sizes

echo "[Aerospace Balance Toggle] ✅ Windows balanced"

# Log action for debugging
echo "$(date '+%Y-%m-%d %H:%M:%S') - Workspace $WORKSPACE: Balanced" >> /tmp/aerospace-balance-toggle.log
