#!/bin/bash
# Verify Symlinks für Aerospace+Sketchybar Setup
# Verhindert Config-Desynchronisation

set -e

echo "🔍 Checking Symlinks..."
echo ""

ERRORS=0

# Check Aerospace Config
echo "1. Aerospace Config (~/.aerospace.toml)"
if [ -L ~/.aerospace.toml ]; then
    TARGET=$(readlink ~/.aerospace.toml)
    if [[ "$TARGET" == *"aerospace+sketchy/configs/aerospace.toml" ]]; then
        echo "   ✅ Symlink OK: $TARGET"
    else
        echo "   ❌ FEHLER: Symlink zeigt auf falsches Ziel: $TARGET"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ❌ FEHLER: Keine Symlink! Ist normale Datei."
    echo "   FIX: rm ~/.aerospace.toml && ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml ~/.aerospace.toml"
    ERRORS=$((ERRORS + 1))
fi

echo ""

# Check Sketchybar Config
echo "2. Sketchybar Config (~/.config/sketchybar)"
if [ -L ~/.config/sketchybar ]; then
    TARGET=$(readlink ~/.config/sketchybar)
    if [[ "$TARGET" == *"aerospace+sketchy/configs/sketchybar" ]]; then
        echo "   ✅ Symlink OK: $TARGET"
    else
        echo "   ❌ FEHLER: Symlink zeigt auf falsches Ziel: $TARGET"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "   ❌ FEHLER: Keine Symlink! Ist normales Verzeichnis."
    echo "   FIX: rm -rf ~/.config/sketchybar && ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/sketchybar ~/.config/sketchybar"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo "✅ Alle Symlinks korrekt!"
    exit 0
else
    echo "❌ $ERRORS Fehler gefunden! Bitte fixen."
    exit 1
fi
