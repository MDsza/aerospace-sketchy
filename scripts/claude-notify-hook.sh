#!/bin/bash
# Claude Code Notification Hook
# Triggers SketchyBar + iPhone notifications when Claude Code events occur
# Usage: Called automatically by Claude Code hooks system (GLOBAL for all projects)

set -e

# Flag file to signal waiting state
FLAG_FILE="/tmp/claude-waiting-flag"

# MyPing wrapper for iPhone notifications (respects 3-mode system: immediate/delayed/off)
MYPING_WRAPPER="$HOME/.claude/skills/myping-notify/myping-wrapper.sh"

# Read JSON from stdin (Claude Code provides this)
JSON_INPUT=$(cat)

# Extract hook event name
HOOK_EVENT=$(echo "$JSON_INPUT" | jq -r '.hook_event_name // "unknown"')

# Set flag based on hook type
case "$HOOK_EVENT" in
    "Notification")
        # Claude is waiting for input - create flag file
        touch "$FLAG_FILE"
        echo "waiting" > "$FLAG_FILE"

        # Send iPhone notification (respects green/blue/grey mode)
        if [ -x "$MYPING_WRAPPER" ]; then
            "$MYPING_WRAPPER" --title '⏸️ Claude Code' --message 'Warte auf Eingabe' &
        fi
        ;;
    "Stop")
        # Claude finished responding - set to "ready" state (green icon)
        touch "$FLAG_FILE"
        echo "ready" > "$FLAG_FILE"

        # Send iPhone notification (respects green/blue/grey mode)
        if [ -x "$MYPING_WRAPPER" ]; then
            "$MYPING_WRAPPER" --title '✅ Claude Code' --message 'Antwort fertig' &
        fi
        ;;
    *)
        # Unknown event - log for debugging
        echo "[Claude Hook] Unknown event: $HOOK_EVENT" >&2
        ;;
esac

exit 0
