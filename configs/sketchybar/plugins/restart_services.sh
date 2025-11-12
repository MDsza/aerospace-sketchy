#!/bin/bash
# Aerospace + Sketchybar Neustart (ROBUST MIT ZOMBIE-PREVENTION)

# Benachrichtigung Start
osascript -e 'display notification "Aerospace + Sketchybar werden neu gestartet..." with title "Restart"' &

# ============================================================================
# HELPER: Wait for process exit
# ============================================================================
wait_for_exit() {
  local process_pattern="$1"
  local max_wait="${2:-5}"  # Default 5 seconds
  local waited=0

  while [ $waited -lt $max_wait ]; do
    if ! pgrep -f "$process_pattern" > /dev/null 2>&1; then
      return 0  # Process gone
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1  # Timeout
}

# ============================================================================
# PHASE 1: GRACEFUL SHUTDOWN (TERM statt -9)
# ============================================================================

# Aerospace graceful shutdown
pkill -TERM AeroSpace 2>/dev/null
wait_for_exit "AeroSpace" 3

# Sketchybar graceful shutdown (erlaubt Cleanup)
pkill -TERM sketchybar 2>/dev/null

# CRITICAL: Wait for Lua workers to exit (max 5s)
echo "Waiting for Lua workers to exit gracefully..."
if ! wait_for_exit "lua.*sketchybarrc" 5; then
  echo "WARNING: Lua workers didn't exit gracefully, forcing..."
fi

# ============================================================================
# PHASE 2: FORCE KILL IF STILL RUNNING
# ============================================================================

# Force kill any survivors
pkill -9 AeroSpace 2>/dev/null
pkill -9 sketchybar 2>/dev/null

# CRITICAL: Force kill Lua zombies in loop until gone
MAX_ATTEMPTS=10
attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  if ! pgrep -f "lua.*sketchybarrc" > /dev/null 2>&1; then
    echo "All Lua processes terminated successfully"
    break
  fi

  echo "Attempt $((attempt+1))/$MAX_ATTEMPTS: Killing Lua zombies..."
  pkill -9 -f "lua.*sketchybarrc" 2>/dev/null
  sleep 1
  attempt=$((attempt + 1))
done

# Final check
if pgrep -f "lua.*sketchybarrc" > /dev/null 2>&1; then
  echo "ERROR: Lua zombies survived all kill attempts!"
  osascript -e 'display notification "CRITICAL: Lua zombies could not be killed. System restart may be needed." with title "Restart Failed"' &
  exit 1
fi

# ============================================================================
# PHASE 3: LOCK-FILE CLEANUP
# ============================================================================

# Remove lock file
rm -f /tmp/sketchybar_$USER.lock 2>/dev/null

# Verify lock file is gone
if [ -e /tmp/sketchybar_$USER.lock ]; then
  echo "ERROR: Lock file still exists!"
  exit 1
fi

# Extra safety wait
sleep 2

# ============================================================================
# PHASE 4: RESTART (only after lock file verified gone)
# ============================================================================

# Final verification before restart
echo "Final pre-flight checks..."
if [ -e /tmp/sketchybar_$USER.lock ]; then
  echo "ERROR: Lock file reappeared!"
  exit 1
fi

if pgrep -f "lua.*sketchybarrc" > /dev/null 2>&1; then
  echo "ERROR: Lua processes reappeared!"
  exit 1
fi

# Starte Aerospace
echo "Starting Aerospace..."
open -a AeroSpace
sleep 3

# CRITICAL: Force reload config (open -a lädt keine Config!)
echo "Reloading Aerospace config..."
aerospace reload-config
sleep 1

# Starte Sketchybar
echo "Starting Sketchybar..."
/opt/homebrew/bin/sketchybar &
SKETCHYBAR_PID=$!

# Wait for Sketchybar to fully initialize
sleep 4

# ============================================================================
# HEALTH-CHECK: Final Process Verification
# ============================================================================

# Count sketchybar + lua processes (should be exactly 2)
count_processes() {
  local sketchybar_count lua_count
  sketchybar_count=$(pgrep -x sketchybar | wc -l | tr -d ' ')
  lua_count=$(pgrep -f "/sketchybar/.*lua" | wc -l | tr -d ' ')
  echo $((sketchybar_count + lua_count))
}

log_process_list() {
  local pids
  pids=$(pgrep -f 'sketchybar|lua .*sketchybarrc' | tr '\n' ' ')
  if [ -n "$pids" ]; then
    ps -o pid,command -p "$pids" > /tmp/sketchybar_process_dump.log 2>/dev/null || true
  else
    echo "Keine Sketchybar-Prozesse aktiv" > /tmp/sketchybar_process_dump.log
  fi
  echo "📄 Prozessliste gespeichert in /tmp/sketchybar_process_dump.log"
}

wait_for_sketchybar_ready() {
  local attempts=0 max_attempts=6
  while [ $attempts -lt $max_attempts ]; do
    local current
    current=$(count_processes)
    if [ "$current" -ge 2 ]; then
      echo "Sketchybar bereit mit $current Prozessen."
      return 0
    fi
    echo "Sketchybar wartet noch auf Lua-Worker ($current/2). Versuch $((attempts + 1))/$max_attempts..."
    sleep 1
    attempts=$((attempts + 1))
  done
  return 1
}

wait_for_sketchybar_ready || true
PROCS=$(count_processes)
echo "Process count: $PROCS (expected: 2)"

if [ "$PROCS" -eq 2 ]; then
  echo "✅ Process count correct (2)"
elif [ "$PROCS" -gt 2 ]; then
  echo "⚠️  WARNING: Too many processes ($PROCS)!"
  log_process_list
  osascript -e "display notification \"WARNUNG: $PROCS Prozesse (erwartet: 2). Mögliche Zombies!\" with title \"Restart Check\"" &
else
  echo "❌ ERROR: Too few Prozesse ($PROCS)!"
  log_process_list
  osascript -e "display notification \"FEHLER: Nur $PROCS Prozesse! Sketchybar nicht gestartet?\" with title \"Restart Failed\"" &
  exit 1
fi

# ============================================================================
# HEALTH-CHECK: Workspaces geladen (sollte ≥14 sein: 1-9,E,T,C,B,M)
# ============================================================================
WORKSPACES=$(sketchybar --query bar 2>/dev/null | grep "space\." | wc -l | tr -d ' ')
echo "Workspaces loaded: $WORKSPACES"

if [ -z "$WORKSPACES" ] || [ "$WORKSPACES" -lt 14 ]; then
  echo "⚠️  WARNING: Only $WORKSPACES workspaces loaded (expected: 14+)"
  osascript -e "display notification \"Nur $WORKSPACES Workspaces geladen. Bitte prüfen!\" with title \"Restart Check\"" &
fi

# ============================================================================
# SUCCESS
# ============================================================================
echo "✅ Restart completed successfully!"
osascript -e "display notification \"Restart erfolgreich! $WORKSPACES Workspaces, $PROCS Prozesse.\" with title \"Aerospace + Sketchybar\"" &

exit 0
