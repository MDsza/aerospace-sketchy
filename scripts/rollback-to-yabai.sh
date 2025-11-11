#!/bin/bash

# Rollback to Yabai+SKHD+Sketchybar
# Reverses Aerospace migration
# Version: 1.0

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$PROJECT_DIR/backup"
YABAI_PROJECT="$HOME/MyCloud/TOOLs/yabai-skhd-sbar"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 ROLLBACK TO YABAI+SKHD+SKETCHYBAR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if backups exist
if [[ ! -f "$BACKUP_DIR/Brewfile.backup" ]]; then
    echo "❌ ERROR: Backup nicht gefunden in $BACKUP_DIR"
    echo "Bitte Phase 1 Backups wiederherstellen!"
    exit 1
fi

echo "⚠️  WARNUNG: Aerospace wird deaktiviert, Yabai+SKHD werden reaktiviert"
echo ""
read -p "Fortfahren? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Abgebrochen."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Aerospace deaktivieren"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if brew list --cask aerospace &>/dev/null; then
    echo "⏸️  Stoppe Aerospace..."

    # LaunchAgent deaktivieren falls vorhanden
    if [[ -f "$HOME/Library/LaunchAgents/com.nikitabobko.aerospace.plist" ]]; then
        launchctl bootout gui/$(id -u)/com.nikitabobko.aerospace 2>/dev/null || true
        echo "✅ Aerospace LaunchAgent deaktiviert"
    fi

    # Option: Komplett deinstallieren
    read -p "Aerospace komplett deinstallieren? (y/n, default: n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew uninstall --cask aerospace
        echo "✅ Aerospace deinstalliert"
    else
        echo "✅ Aerospace bleibt installiert (nur deaktiviert)"
    fi
else
    echo "ℹ️  Aerospace nicht installiert, überspringe..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Yabai + SKHD aus Backup wiederherstellen"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if yabai/skhd are installed
NEED_INSTALL=false

if ! brew list yabai &>/dev/null; then
    echo "⚠️  Yabai nicht installiert"
    NEED_INSTALL=true
fi

if ! brew list skhd &>/dev/null; then
    echo "⚠️  SKHD nicht installiert"
    NEED_INSTALL=true
fi

if [[ "$NEED_INSTALL" == "true" ]]; then
    echo ""
    echo "📦 Installiere Yabai + SKHD aus Brewfile..."
    brew bundle install --file="$BACKUP_DIR/Brewfile.backup"
    echo "✅ Yabai + SKHD installiert"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Configs wiederherstellen"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Git checkout v-yabai-final
if [[ -d "$YABAI_PROJECT" ]]; then
    echo "📂 Checkout v-yabai-final im Basis-Projekt..."
    cd "$YABAI_PROJECT"
    git fetch --tags
    git checkout v-yabai-final
    echo "✅ Git checkout erfolgreich"

    # Restore configs via restore-configs.sh
    if [[ -f "$YABAI_PROJECT/scripts/restore-configs.sh" ]]; then
        echo "🔄 Restore configs..."
        bash "$YABAI_PROJECT/scripts/restore-configs.sh"
        echo "✅ Configs restored"
    else
        echo "⚠️  restore-configs.sh nicht gefunden, manuelle Symlinks..."
        ln -sf "$YABAI_PROJECT/configs/yabai/main_config" ~/.yabairc
        ln -sf "$YABAI_PROJECT/configs/skhd/.skhdrc" ~/.skhdrc
        ln -sf "$YABAI_PROJECT/configs/sketchybar" ~/.config/sketchybar
        echo "✅ Symlinks erstellt"
    fi
else
    echo "❌ ERROR: Yabai-Projekt nicht gefunden: $YABAI_PROJECT"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Karabiner wiederherstellen"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -d "$BACKUP_DIR/karabiner-backup/karabiner" ]]; then
    echo "🔄 Restore Karabiner-Config..."
    cp -r "$BACKUP_DIR/karabiner-backup/karabiner/"* ~/.config/karabiner/
    echo "✅ Karabiner-Config restored"
else
    echo "ℹ️  Kein Karabiner-Backup gefunden, überspringe..."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Services neu starten"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "🔄 Starte Yabai..."
brew services restart yabai
sleep 2

echo "🔄 Starte SKHD..."
brew services restart skhd
sleep 1

echo "🔄 Starte Sketchybar..."
brew services restart sketchybar
sleep 2

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Status prüfen"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "Service Status:"
brew services list | grep -E 'yabai|skhd|sketchybar'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ROLLBACK ABGESCHLOSSEN!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "System läuft jetzt wieder mit Yabai+SKHD+Sketchybar"
echo ""
echo "📋 Nächste Schritte:"
echo "   1. System-Neustart empfohlen"
echo "   2. Prüfe ob alle Shortcuts funktionieren"
echo "   3. Prüfe Sketchybar-Anzeige"
echo ""
echo "🔄 Falls weiterhin Probleme:"
echo "   - Complete Backup restore: ~/MyCloud/TOOLs/_TOOLs-BACKUPs/yabai-skhd-sbar/"
echo "   - RESTORE-INSTRUCTIONS.md im Backup-Archiv"
echo ""
