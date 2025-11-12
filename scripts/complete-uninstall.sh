#!/bin/bash
# COMPLETE UNINSTALL - Aerospace + Yabai + SKHD + Sketchybar + Lua
# Für kompletten Neuanfang

set -e

echo "🔴 COMPLETE UNINSTALL STARTING..."
echo "Dies entfernt ALLES: Aerospace, Yabai, SKHD, Sketchybar, Lua"
echo ""
read -p "Wirklich fortfahren? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Abbruch."
    exit 1
fi

echo ""
echo "============================================================================"
echo "PHASE 1: ALLE PROZESSE KILLEN"
echo "============================================================================"

# Kill all processes
killall -9 AeroSpace 2>/dev/null || true
killall -9 sketchybar 2>/dev/null || true
killall -9 yabai 2>/dev/null || true
killall -9 skhd 2>/dev/null || true
killall -9 lua 2>/dev/null || true

echo "✅ Alle Prozesse gestoppt"

sleep 2

echo ""
echo "============================================================================"
echo "PHASE 2: HOMEBREW SERVICES STOPPEN"
echo "============================================================================"

brew services stop sketchybar 2>/dev/null || true
brew services stop yabai 2>/dev/null || true
brew services stop skhd 2>/dev/null || true

echo "✅ Alle Services gestoppt"

echo ""
echo "============================================================================"
echo "PHASE 3: LAUNCH AGENTS ENTFERNEN"
echo "============================================================================"

# Aerospace LaunchAgent
if [ -f ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist ]; then
    launchctl bootout gui/$(id -u)/com.nikitabobko.aerospace 2>/dev/null || true
    rm ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist
    echo "✅ Aerospace LaunchAgent entfernt"
fi

# Yabai LaunchAgent
if [ -f ~/Library/LaunchAgents/com.koekeishiya.yabai.plist ]; then
    launchctl bootout gui/$(id -u)/com.koekeishiya.yabai 2>/dev/null || true
    rm ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
    echo "✅ Yabai LaunchAgent entfernt"
fi

# SKHD LaunchAgent
if [ -f ~/Library/LaunchAgents/com.koekeishiya.skhd.plist ]; then
    launchctl bootout gui/$(id -u)/com.koekeishiya.skhd 2>/dev/null || true
    rm ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
    echo "✅ SKHD LaunchAgent entfernt"
fi

echo ""
echo "============================================================================"
echo "PHASE 4: HOMEBREW PACKAGES DEINSTALLIEREN"
echo "============================================================================"

# Aerospace
if brew list --cask aerospace &>/dev/null; then
    brew uninstall --cask aerospace
    echo "✅ Aerospace deinstalliert"
fi

# Yabai
if brew list yabai &>/dev/null; then
    brew uninstall yabai
    echo "✅ Yabai deinstalliert"
fi

# SKHD
if brew list skhd &>/dev/null; then
    brew uninstall skhd
    echo "✅ SKHD deinstalliert"
fi

# Sketchybar
if brew list sketchybar &>/dev/null; then
    brew uninstall sketchybar
    echo "✅ Sketchybar deinstalliert"
fi

# Lua (VORSICHT: Kann andere Dependencies haben!)
echo "⚠️  Lua NICHT deinstalliert (kann andere Dependencies brechen)"
echo "   Falls gewünscht: brew uninstall lua"

echo ""
echo "============================================================================"
echo "PHASE 5: CONFIG-DATEIEN ENTFERNEN"
echo "============================================================================"

# Aerospace Config
if [ -L ~/.aerospace.toml ]; then
    rm ~/.aerospace.toml
    echo "✅ Aerospace Config Symlink entfernt"
elif [ -f ~/.aerospace.toml ]; then
    rm ~/.aerospace.toml
    echo "✅ Aerospace Config Datei entfernt"
fi

# Yabai Config
if [ -f ~/.yabairc ]; then
    mv ~/.yabairc ~/.yabairc.backup-$(date +%Y%m%d-%H%M%S)
    echo "✅ Yabai Config gesichert und entfernt"
fi

# SKHD Config
if [ -f ~/.skhdrc ]; then
    mv ~/.skhdrc ~/.skhdrc.backup-$(date +%Y%m%d-%H%M%S)
    echo "✅ SKHD Config gesichert und entfernt"
fi

# Sketchybar Config
if [ -L ~/.config/sketchybar ]; then
    rm ~/.config/sketchybar
    echo "✅ Sketchybar Config Symlink entfernt"
elif [ -d ~/.config/sketchybar ]; then
    mv ~/.config/sketchybar ~/.config/sketchybar.backup-$(date +%Y%m%d-%H%M%S)
    echo "✅ Sketchybar Config gesichert und entfernt"
fi

echo ""
echo "============================================================================"
echo "PHASE 6: TEMP-DATEIEN AUFRÄUMEN"
echo "============================================================================"

# Lock Files
rm -f /tmp/sketchybar_$USER.lock
echo "✅ Sketchybar Lock-File entfernt"

# Logs
rm -f /tmp/sketchybar_apple_handler.log
rm -f /tmp/sketchybar_process_dump.log
echo "✅ Log-Dateien entfernt"

# Lua Sketchybar Module
if [ -d ~/.local/share/sketchybar_lua ]; then
    rm -rf ~/.local/share/sketchybar_lua
    echo "✅ Sketchybar Lua Module entfernt"
fi

echo ""
echo "============================================================================"
echo "PHASE 7: VERIFICATION"
echo "============================================================================"

echo ""
echo "Prozesse:"
ps aux | grep -E 'AeroSpace|sketchybar|yabai|skhd' | grep -v grep || echo "  ✅ Keine Prozesse laufen"

echo ""
echo "Homebrew Packages:"
brew list | grep -E 'aerospace|yabai|skhd|sketchybar' || echo "  ✅ Keine Packages installiert"

echo ""
echo "Config-Dateien:"
ls -la ~/.aerospace.toml ~/.yabairc ~/.skhdrc ~/.config/sketchybar 2>/dev/null || echo "  ✅ Keine Configs vorhanden"

echo ""
echo "============================================================================"
echo "✅ COMPLETE UNINSTALL FINISHED!"
echo "============================================================================"
echo ""
echo "System ist jetzt komplett clean."
echo ""
echo "NÄCHSTE SCHRITTE für Neuinstallation:"
echo "1. System NEU STARTEN (empfohlen)"
echo "2. Aerospace neu installieren: brew install --cask nikitabobko/tap/aerospace"
echo "3. Sketchybar neu installieren: brew install sketchybar"
echo "4. Configs aus diesem Projekt neu symlinken"
echo ""
echo "⚠️  KARABINER bleibt installiert (CapsLock → Hyper)"
echo ""
