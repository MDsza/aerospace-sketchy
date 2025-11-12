#!/bin/bash
# get-app-id.sh
# Get bundle ID of focused window for Aerospace workspace assignment
# Usage: Open the app you want to check, then run this script

set -e

echo "Getting focused window app-id..."
echo ""

# Method 1: Via Aerospace
APP_ID=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null | head -1)

if [ -n "$APP_ID" ]; then
  echo "✅ App Bundle ID (Aerospace):"
  echo "   $APP_ID"
  echo ""
  echo "Add to .aerospace.toml:"
  echo "[[on-window-detected]]"
  echo "if.app-id = '$APP_ID'"
  echo "run = 'move-node-to-workspace X'  # Replace X with workspace"
else
  echo "❌ Could not detect app-id via Aerospace"
  echo ""
  echo "Alternative: Use AppleScript to get frontmost app"

  # Method 2: Via AppleScript
  osascript <<EOF
tell application "System Events"
  set frontApp to first application process whose frontmost is true
  set appName to name of frontApp
  set appBundleID to bundle identifier of frontApp
end tell

"App Name: " & appName & "
Bundle ID: " & appBundleID
EOF
fi

echo ""
echo "To list all running apps with bundle IDs:"
echo "  aerospace list-windows --all --format '%{app-bundle-id}' | sort -u"
