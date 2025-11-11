#!/bin/bash
# Toggle MyPing Skill for Claude Code
# 3-state cycle: immediate → delayed → off → immediate

set -e

# Log file for debugging
LOG_FILE="/tmp/myping-toggle.log"
echo "=== Toggle started at $(date) ===" >> "$LOG_FILE"

SKILL_DIR="$HOME/.claude/skills/myping-notify"
SKILL_DISABLED="$HOME/.claude/skills/myping-notify.disabled"
MODE_FILE="$HOME/.config/myping/mode"
LOCK_FILE="/tmp/myping-toggle.lock"

# Lock mechanism to prevent concurrent toggles
if [ -f "$LOCK_FILE" ]; then
    echo "Toggle already in progress..." | tee -a "$LOG_FILE"
    exit 0
fi
touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Read current mode (if file doesn't exist, detect from skill state)
if [ -f "$MODE_FILE" ]; then
    CURRENT_MODE=$(cat "$MODE_FILE")
else
    # Fallback: detect from skill state
    if [ -e "$SKILL_DIR" ]; then
        CURRENT_MODE="immediate"
    else
        CURRENT_MODE="off"
    fi
fi

echo "Current mode: $CURRENT_MODE" | tee -a "$LOG_FILE"

# Cycle through states: immediate → delayed → off → immediate
case "$CURRENT_MODE" in
    immediate)
        NEW_MODE="delayed"
        ;;
    delayed)
        NEW_MODE="off"
        ;;
    off|*)
        NEW_MODE="immediate"
        ;;
esac

echo "New mode: $NEW_MODE" | tee -a "$LOG_FILE"

# Write new mode to config
echo "$NEW_MODE" > "$MODE_FILE"

# Enable/disable skill based on mode
if [ "$NEW_MODE" = "off" ]; then
    # Disable skill
    if [ -e "$SKILL_DIR" ]; then
        if ! mv "$SKILL_DIR" "$SKILL_DISABLED" 2>/dev/null; then
            echo "✗ Error: Cannot disable skill" | tee -a "$LOG_FILE"
            exit 1
        fi
        echo "✓ Skill disabled" | tee -a "$LOG_FILE"
    fi
else
    # Enable skill (immediate or delayed)
    if [ -e "$SKILL_DISABLED" ]; then
        if ! mv "$SKILL_DISABLED" "$SKILL_DIR" 2>/dev/null; then
            echo "✗ Error: Cannot enable skill" | tee -a "$LOG_FILE"
            exit 1
        fi
        echo "✓ Skill enabled (mode: $NEW_MODE)" | tee -a "$LOG_FILE"
    fi
fi

# Trigger SketchyBar update
sketchybar --trigger myping_update

# Send test notification only in immediate mode
if [ "$NEW_MODE" = "immediate" ]; then
    echo "Sending test notification (immediate mode)..." | tee -a "$LOG_FILE"
    if /usr/local/bin/myping --title '🟢 MyPing Immediate' --message 'Test: Notifications will be sent instantly' 2>&1 | tee -a "$LOG_FILE"; then
        echo "✓ Test notification sent" | tee -a "$LOG_FILE"
    else
        echo "✗ Failed to send test notification" | tee -a "$LOG_FILE"
    fi
elif [ "$NEW_MODE" = "delayed" ]; then
    echo "ℹ️  Delayed mode active - notifications only when idle >60s" | tee -a "$LOG_FILE"
fi

echo "MyPing mode: $NEW_MODE" | tee -a "$LOG_FILE"
echo "=== Toggle finished at $(date) ===" >> "$LOG_FILE"
