#!/bin/bash
# center-mouse.sh
# Center mouse on focused window (mouse-follows-focus)

# Get focused window bounds using JXA (since Aerospace doesn't provide window geometry)
WINDOW_BOUNDS=$(osascript -l JavaScript -e '
  const sys = Application("System Events");
  const procs = sys.applicationProcesses.whose({ frontmost: true });
  if (procs.length === 0) quit();
  const proc = procs[0];
  const wins = proc.windows();
  if (wins.length === 0) quit();
  const win = wins[0];
  const pos = win.position();
  const size = win.size();
  `${pos[0]} ${pos[1]} ${size[0]} ${size[1]}`;
' 2>/dev/null)

if [ -z "$WINDOW_BOUNDS" ]; then
  # No focused window
  exit 0
fi

# Parse window bounds
read -r WIN_X WIN_Y WIN_W WIN_H <<< "$WINDOW_BOUNDS"

# Calculate center position
CENTER_X=$((WIN_X + WIN_W / 2))
CENTER_Y=$((WIN_Y + WIN_H / 2))

# Move mouse to center using cliclick (preferred) or Swift fallback
if command -v cliclick &> /dev/null; then
  cliclick m:$CENTER_X,$CENTER_Y 2>/dev/null
else
  # Fallback: Use Swift/CoreGraphics
  /usr/bin/swift - "$CENTER_X" "$CENTER_Y" 2>/dev/null <<'SWIFTCODE' || exit 0
import CoreGraphics
guard CommandLine.arguments.count >= 3,
      let x = Double(CommandLine.arguments[1]),
      let y = Double(CommandLine.arguments[2]) else { exit(1) }
CGWarpMouseCursorPosition(CGPoint(x: x, y: y))
SWIFTCODE
fi
