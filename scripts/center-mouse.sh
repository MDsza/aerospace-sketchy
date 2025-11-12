#!/bin/bash
# center-mouse.sh
# Center mouse on focused window (mouse-follows-focus)

set -e

# Get focused window position and size
WINDOW_INFO=$(aerospace list-windows --focused --format '%{window-id} %{window-x} %{window-y} %{window-width} %{window-height}' 2>/dev/null | head -1)

if [ -z "$WINDOW_INFO" ]; then
  # No focused window
  exit 0
fi

# Parse window info
read -r WIN_ID WIN_X WIN_Y WIN_W WIN_H <<< "$WINDOW_INFO"

# Calculate center position
CENTER_X=$((WIN_X + WIN_W / 2))
CENTER_Y=$((WIN_Y + WIN_H / 2))

# Move mouse to center using cliclick
if command -v cliclick &> /dev/null; then
  cliclick m:$CENTER_X,$CENTER_Y 2>/dev/null
else
  # Fallback: AppleScript
  osascript -e "
    tell application \"System Events\"
      set frontProcess to first process whose frontmost is true
      tell frontProcess
        set position of window 1 to {$WIN_X, $WIN_Y}
      end tell
    end tell

    do shell script \"printf '\\033[3;${CENTER_X};${CENTER_Y}t' > /dev/tty\"
  " 2>/dev/null || true
fi
