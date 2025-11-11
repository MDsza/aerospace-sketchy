# CLAUDE.md

Projekt-Kontext für Claude Code bei der Arbeit mit diesem Repository.

## Projekt-Übersicht

**Ziel:** Migration von Yabai+SKHD+Sketchybar zu Aerospace+Sketchybar

**Basis-Projekt:** `~/MyCloud/TOOLs/yabai-skhd-sbar`
- Vollständig analysiert und dokumentiert
- Production-ready v2.7.2
- 40+ Keyboard Shortcuts (SKHD)
- 20 Spaces mit Sketchybar-Integration
- Karabiner für Hyper-Key (CapsLock → ⌃⌥⇧⌘)

## Technologie-Stack

### Aktuell (Yabai-Setup)
- **Window Manager:** Yabai (--HEAD für macOS Sequoia)
- **Keyboard Daemon:** SKHD
- **Status Bar:** Sketchybar (Lua-basiert)
- **Key Remapping:** Karabiner-Elements
- **Dependencies:** jq, cliclick, macmon

### Ziel (Aerospace-Setup)
- **Window Manager:** Aerospace (i3-inspiriert)
- **Keyboard:** Aerospace built-in (TOML-Config)
- **Status Bar:** Sketchybar (angepasst)
- **Key Remapping:** Karabiner-Elements (bleibt!)
- **Vorteil:** KEIN SIP-Disable nötig

## Wichtige Unterschiede Yabai ↔ Aerospace

### Workspace-Konzept
- **Yabai:** Native macOS Spaces (Mission Control integriert)
- **Aerospace:** Eigene virtuelle Workspaces (unabhängig von macOS)
  - Fenster verschwinden aus Mission Control
  - i3-Style Workspace-System
  - Beliebige IDs: Zahlen + Buchstaben

### Keyboard Shortcuts
- **Yabai:** Externe SKHD-Config (~/.skhdrc)
- **Aerospace:** Built-in (~/.aerospace.toml)
  - Kein separater Daemon nötig
  - Modifier-Support: cmd, alt, ctrl, shift
  - Binding Modes möglich

### Layouts
- **Yabai:** BSP, Stack, Float
- **Aerospace:** tiles (h/v), accordion (h/v), floating
  - Kein klassischer Stack-Mode
  - Accordion ähnelt Stack

### Sicherheit
- **Yabai:** SIP-Disable für volle Features
- **Aerospace:** Nur Accessibility (keine SIP-Änderung)

## Projekt-Struktur

```
aerospace+sketchy/
├── CLAUDE.md              # Dieser File
├── README.md              # Setup-Anleitung
├── PLAN.md                # Migrations-Plan (wird nach jeder Phase aktualisiert!)
├── SHORTCUTS.md           # Transition Cheat Sheet (Yabai→Aerospace)
├── configs/
│   ├── aerospace.toml     # Hauptconfig (Draft/Final)
│   └── sketchybar/        # Angepasste Sketchybar-Configs
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

## Migrations-Status

**Aktuell:** Phase 0 - Vorbereitung / Dokumentation

**Nächste Schritte:**
1. Phase 1: Backup & Safety (yabai-skhd-sbar committen/pushen)
2. Phase 2: Aerospace Installation
3. Phase 3: Config Migration (Draft → Testing)

## Wichtige Dateien Basis-Projekt

### Yabai-Config
- `~/MyCloud/TOOLs/yabai-skhd-sbar/configs/yabai/main_config` (158 Zeilen)
- Zentral: `configs/shared/bar_config.sh` (SKETCHYBAR_HEIGHT=30)
- Window Rules für System-Apps (manage=off)
- Signals für Sketchybar-Updates

### SKHD-Config
- `~/MyCloud/TOOLs/yabai-skhd-sbar/configs/skhd/.skhdrc` (290 Zeilen)
- 40+ Shortcuts mit Hyper/Hyper+ Modifiers
- Hyper = ⌃⌥⇧ (CapsLock via Karabiner)
- Hyper+ = ⌃⌥⇧⌘ (CapsLock+CMD via Karabiner)

### Sketchybar-Config
- `~/MyCloud/TOOLs/yabai-skhd-sbar/configs/sketchybar/`
- Lua-basiert (sketchybarrc → bar_config.lua)
- Spaces Widget: 20 Spaces mit App-Icons
- Widgets: CPU, Memory, Network, Battery, Claude-Notifier
- Performance-Optimiert: Update Manager + Batch Queries

### Karabiner-Config
- `~/.config/karabiner/karabiner.json`
- CapsLock → Hyper (⌃⌥⇧)
- CapsLock+CMD → Hyper+ (⌃⌥⇧⌘)
- CMD_R → Hyper/Hyper+ (Alternative zu CapsLock)
- Wird BEIBEHALTEN im neuen Setup!

## Workspace-Mapping (Geplant)

```
Hybrid-System: 9 Zahlen + 5 Buchstaben

1-9  → Standard Workspaces (wie bisher)
C    →  Code (VS Code, Terminal)
M    →  Music (Spotify, iTunes)
B    →  Browser (Safari, Firefox)
E    → ✉ Email (Mail.app)
T    →  Terminal (dediziert)
```

## Konventionen & Guidelines

### Code-Style
- **Bash-Scripts:** Shebang, set -e für kritische Operationen
- **Versioning:** Semantic (v2.7.1 Style)
- **Comments:** Funktions-Header mit Purpose/Logic/Features

### Config-Management
- **Symlinks:** Project → System (~/.aerospace.toml)
- **Backups:** Timestamped in backup/
- **Restore:** Scripts für Rollback

### Testing
- Immer auf Multi-Monitor testen
- Externe Tastatur-Szenarien prüfen
- Edge Cases dokumentieren

## Rollback-Strategie

**Soft-Rollback (Erste 2 Wochen):**
```bash
./scripts/rollback-to-yabai.sh
# Aerospace disable, Yabai/SKHD services restart
```

**Hard-Rollback (Falls Aerospace komplett unbrauchbar):**
```bash
git checkout v-yabai-final  # Im Basis-Projekt
./scripts/restore-configs.sh
brew bundle install --file=Brewfile.backup
```

## Ressourcen

- **Aerospace Docs:** https://nikitabobko.github.io/AeroSpace/guide
- **Basis-Projekt:** ~/MyCloud/TOOLs/yabai-skhd-sbar
- **Community Configs:** GitHub "aerospace sketchybar dotfiles"

## Wichtige Hinweise

1. **PLAN.md nach jeder Phase aktualisieren!**
2. **Backups IMMER vor System-Eingriffen!**
3. **Karabiner nicht entfernen** (CapsLock-Mapping)
4. **Soft-Disable Yabai/SKHD** vor Hard-Remove
5. **Accessibility nach Aerospace-Update** neu aktivieren
