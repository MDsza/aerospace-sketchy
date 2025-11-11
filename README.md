# Aerospace + Sketchybar Setup

Migration von Yabai+SKHD zu Aerospace mit beibehaltener Sketchybar-Integration.

## Status

**Aktuell:** Phase 0 - Vorbereitung & Dokumentation

**Migrations-Fortschritt:** Siehe [PLAN.md](PLAN.md)

## Projekt-Übersicht

Dieses Projekt dokumentiert die Migration eines produktiven Yabai+SKHD+Sketchybar-Setups zu Aerospace+Sketchybar.

### Ausgangspunkt
- **Basis:** `~/MyCloud/TOOLs/yabai-skhd-sbar` (v2.7.2)
- **Yabai:** BSP-Layout, 20 Spaces, Multi-Monitor
- **SKHD:** 40+ Keyboard Shortcuts mit Hyper-Key
- **Sketchybar:** Lua-basiert, Performance-optimiert
- **Karabiner:** CapsLock → Hyper (⌃⌥⇧⌘)

### Ziel
- **Aerospace:** i3-inspirierter Window Manager
- **Virtuelle Workspaces:** 1-9 + C/M/B/E/T (Hybrid)
- **Built-in Shortcuts:** Kein separater SKHD
- **Sketchybar:** Angepasst für Aerospace
- **Karabiner:** Beibehalten für Hyper-Key
- **Vorteil:** Kein SIP-Disable nötig!

## Warum Aerospace?

### Vorteile
✅ Kein SIP-Disable (nur Accessibility)
✅ All-in-One Config (TOML)
✅ i3-inspirierte Workflows
✅ Bessere Performance (v.a. Intel Macs)
✅ Built-in Keyboard Handling
✅ Aktive Entwicklung

### Nachteile
⚠️ Eigene virtuelle Workspaces (nicht Mission Control)
⚠️ Battery Impact (versteckte Fenster rendern weiter)
⚠️ Noch Beta (Breaking Changes bis 1.0 möglich)
⚠️ Weniger Features als Yabai

## Installation (Noch nicht ausführen!)

### Phase 1: Backup (KRITISCH!)

```bash
# 1. Basis-Projekt committen
cd ~/MyCloud/TOOLs/yabai-skhd-sbar
git add -A
git commit -m "Final Yabai setup before Aerospace migration"
git tag v-yabai-final
git push origin main --tags

# 2. Homebrew-State sichern
brew bundle dump --file=backup/Brewfile.backup

# 3. Karabiner sichern
cp -r ~/.config/karabiner backup/karabiner-backup/

# 4. Service-State
brew services list > backup/services-state-before.txt
launchctl list | grep -E 'yabai|skhd|sketchybar' > backup/launchctl-before.txt

# 5. Complete Backup
cd ~/MyCloud/TOOLs/yabai-skhd-sbar
./scripts/complete-system-backup.sh
# → Archiv extern sichern!
```

### Phase 2: Aerospace Installation

```bash
# Installation
brew install --cask nikitabobko/tap/aerospace

# Accessibility aktivieren
# System Settings → Privacy & Security → Accessibility → Aerospace ✓

# LaunchAgent prüfen
ls ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist

# Manueller Start (falls nötig)
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist
```

**⚠️ Nach jedem Aerospace-Update:**
Accessibility-Permission toggle OFF/ON!

### Phase 3: Konfiguration

```bash
# Config aus diesem Projekt
cp configs/aerospace.toml ~/.aerospace.toml

# Sketchybar anpassen
# TODO: Nach Config-Migration
```

## Workspace-Konzept

### Hybrid-System (1-9 + Buchstaben)

```
1-9  → Standard Workspaces
C    →  Code (VS Code, Terminal, IDEs)
M    →  Music (Spotify, iTunes, Audio)
B    →  Browser (Safari, Firefox, Chrome)
E    → ✉ Email (Mail.app, Outlook)
T    →  Terminal (dediziert Shell-Sessions)
```

### Shortcuts (Geplant)

Siehe [SHORTCUTS.md](SHORTCUTS.md) für vollständige Transition-Übersicht.

**Beispiele:**
```
Hyper + [1-9,C,M,B,E,T]   → Workspace wechseln
Hyper+ + [1-9,C,M,B,E,T]  → Fenster zu Workspace
Hyper + Pfeile            → Fenster fokussieren
Hyper+ + Pfeile           → Fenster tauschen
Hyper + K                 → Layout toggle (tiles/accordion/float)
```

## Wichtige Unterschiede zu Yabai

### Workspaces
- **Yabai:** Native macOS Spaces (Mission Control)
- **Aerospace:** Eigene virtuelle Workspaces
  - Fenster verschwinden aus Mission Control
  - Cmd+Tab funktioniert weiter
  - Cmd+` weiterhin pro-app cycling

### Layouts
- **BSP/Stack** → **tiles/accordion**
- Balance = automatisch per Shortcut
- Kein klassischer Stack-Mode

### Window-Verhalten
- Minimieren = Verstecken (nicht Dock)
- Weiter-Rendering im Hintergrund (Battery!)
- Kein Shadow-Toggle

## Rollback

### Soft-Rollback (empfohlen erste 2 Wochen)

```bash
./scripts/rollback-to-yabai.sh
```

**Effekt:**
- Aerospace deaktiviert (Binaries bleiben)
- Yabai+SKHD services restart
- Configs restored

### Hard-Rollback

Falls Aerospace komplett unbrauchbar:

```bash
# Im Basis-Projekt
cd ~/MyCloud/TOOLs/yabai-skhd-sbar
git checkout v-yabai-final
./scripts/restore-configs.sh

# Homebrew-State
brew bundle install --file=backup/Brewfile.backup
```

## Projekt-Struktur

```
aerospace+sketchy/
├── CLAUDE.md              # Kontext für Claude Code
├── README.md              # Diese Datei
├── PLAN.md                # Migrations-Plan (wird aktualisiert!)
├── SHORTCUTS.md           # Transition Cheat Sheet
├── configs/
│   ├── aerospace.toml     # Aerospace-Config
│   └── sketchybar/        # Angepasste Sketchybar
├── scripts/
│   ├── rollback-to-yabai.sh
│   ├── aerospace-yabai-bridge.sh
│   └── ... (migrierte Scripts)
├── backup/
│   ├── Brewfile.backup
│   ├── karabiner-backup/
│   └── services-state-before.txt
└── docs/
    ├── breaking-changes.md
    └── workspace-mapping.md
```

## Ressourcen

### Dokumentation
- **Aerospace Guide:** https://nikitabobko.github.io/AeroSpace/guide
- **Commands Reference:** https://nikitabobko.github.io/AeroSpace/commands
- **Goodies:** https://nikitabobko.github.io/AeroSpace/goodies

### Community
- **Aerospace GitHub:** https://github.com/nikitabobko/AeroSpace
- **Dotfiles:** GitHub suche "aerospace sketchybar dotfiles"

### Basis-Projekt
- **Location:** ~/MyCloud/TOOLs/yabai-skhd-sbar
- **Version:** v2.7.2 (final vor Migration)

## Support & Troubleshooting

### Häufige Probleme

**Shortcuts funktionieren nicht:**
```bash
# PRAM Clear nach Installation
# Neustart + Cmd+Opt+P+R beim Boot halten
```

**Accessibility-Fehler:**
```bash
# Toggle OFF/ON in System Settings
# System Settings → Privacy & Security → Accessibility
```

**Sketchybar zeigt keine Workspaces:**
```bash
# Event-Integration prüfen
sketchybar --query bar
sketchybar --reload
```

## Lizenz

Private Setup-Dokumentation, nicht für öffentliche Distribution.

## Kontakt

Bei Fragen zum Basis-Projekt oder Migration siehe:
- Basis-Projekt README: `~/MyCloud/TOOLs/yabai-skhd-sbar/README.md`
- Migrations-Plan: [PLAN.md](PLAN.md)
