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
- **Virtuelle Workspaces:** Fixes QWERTZ-Layout (Q W E R T / A S D F G) + Overflow X/Y/Z
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
# 🔴 WICHTIG: Symlink erstellen (NICHT kopieren!)
# Damit Edits im Projekt sofort wirken
rm -f ~/.aerospace.toml
ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml ~/.aerospace.toml

# Verify Symlink
ls -la ~/.aerospace.toml
# Erwartung: lrwxr-xr-x ... -> .../configs/aerospace.toml

# Sketchybar ist bereits symlinked (Phase 4)
ls -la ~/.config/sketchybar
# Erwartung: lrwxr-xr-x ... -> .../configs/sketchybar
```

**⚠️ NIEMALS `cp` verwenden! Nur Symlinks!**
- **Grund:** Edits im Projekt müssen sofort wirken
- **Sonst:** Config-Desynchronisation → Änderungen wirkungslos

## Workspace-Konzept

### Fixes QWERTZ-System (Q W E R T / A S D F G)

```
### 3.1 Workspace-Setup (QWERTZ Fixlayout)

**Mapping (10 feste Workspaces + Overflow):**
```
Q  → Quick Notes:  Obsidian / Research
W  → Work: Citrix
E  → Email: Messaging / Outlook
R  → Meetings: Reserved
T  → Terminal
A  → AI: IDEs / VS Code
S  → Search: Browser
D  → Do: Productivity
F  → Files: Finder
G  → General: ...
Overflow (X/Y/Z) → Automatisch bei Mehrmonitorbedarf



Overflow: X/Y/Z werden automatisch erstellt, wenn Monitore zusätzliche Workspaces benötigen.
```

### Shortcuts (produktiver Stand)

Siehe [SHORTCUTS.md](SHORTCUTS.md) für vollständige Transition-Übersicht.

**Beispiele:**
```
Hyper + [Q,W,E,R,T,A,S,D,F,G]   → Workspace wechseln
Hyper+ + [Q,W,E,R,T,A,S,D,F,G]  → Fenster in Workspace verschieben (mit Follow)
Hyper + N / M                  → Vorheriger / nächster Workspace
Hyper + J / L                  → Vorheriges / nächstes Fenster (Karussell, wrap-around)
Hyper+ + N / M                 → Fenster in vorherigen/nächsten Workspace verschieben (mit Follow)
Hyper + Pfeile                 → Fokus hoch/runter
Hyper+ + Pfeile                → Fenster tauschen hoch/runter
Hyper + H / V / K             → Tiles horizontal / Tiles vertical / Accordion (toggle mit letztem Tiles-Zustand)
```

### Sketchybar Workspace-Leiste (Final)

- Reihenfolge: `Q W E R T | A S D F G` (Separator = vertikaler Strich), dahinter ggf. `X/Y/Z` wenn Overflow-Workspaces existieren.
- Jeder Buchstabe ist das Icon des jeweiligen Workspaces, die **Label-Zeile zeigt die aktiven Apps** als SF-Symbols aus `configs/sketchybar/helpers/app_icons.lua` (z. B. Obsidian = Tropfen, Citrix = Koffer, VS Code/Claude = Spirale/Stern).
- Die Workspace-Items werden dynamisch aus `configs/sketchybar/items/spaces.lua` erzeugt, reagieren auf `aerospace_workspace_change` und setzen bei Klick sofort `aerospace workspace <LETTER>`.
- **Links:** Apple-Logo unmittelbar gefolgt von Workspace-Items (Q W E R T | A S D F G)
- **Rechts:** Widgets (CPU, Memory, Network, Battery) + Claude-Notifier

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

### 🆘 Vollständige Troubleshooting-Dokumentation

**Siehe [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) für detaillierte Lösungen!**

### Häufige Probleme (Quick Reference)

#### 🔴 CRITICAL: Sketchybar Lock-File-Problem
**Symptom:** `could not acquire lock-file... already running?` oder `could not initialize daemon! abort..`

**Quick Fix:**
```bash
# Methode 1: Brew Services (EMPFOHLEN)
killall -9 sketchybar lua 2>/dev/null
sleep 2
brew services restart sketchybar

# Methode 2: Manuell
pkill -9 sketchybar
pkill -9 -f "lua.*sketchybar"
rm -f /tmp/sketchybar_$USER.lock
sleep 3
sketchybar
```

**📖 Details:** [docs/TROUBLESHOOTING.md - Lock-File-Problem](docs/TROUBLESHOOTING.md#-critical-sketchybar-lock-file-problem)

---

#### ⚠️ Workspaces nicht klickbar / nicht highlighted
**Symptom:** Keine Reaktion auf Klick, keine Hervorhebung beim Wechsel

**Quick Fix:**
```bash
brew services restart sketchybar
sleep 3
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=A
```

**📖 Details:** [docs/TROUBLESHOOTING.md - Workspace-Probleme](docs/TROUBLESHOOTING.md#️-workspace-probleme)

---

#### 🐌 Performance-Probleme / Zombie-Prozesse
**Symptom:** Langsame Reaktion, viele Prozesse laufen

**Quick Fix:**
```bash
# Kill Zombie-Prozesse
pkill -9 -f "aerospace list-"
pkill -9 -f "sketchybar --query"

# Prüfe Prozess-Count
ps aux | grep -E '[s]ketchybar' | wc -l
# Erwartung: 2 (1x sketchybar, 1x lua)
```

**📖 Details:** [docs/TROUBLESHOOTING.md - Performance](docs/TROUBLESHOOTING.md#-performance-probleme)

---

### Weitere häufige Probleme

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

**📖 Vollständige Diagnostics & Notfall-Reset:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Lizenz

Private Setup-Dokumentation, nicht für öffentliche Distribution.

## Kontakt

Bei Fragen zum Basis-Projekt oder Migration siehe:
- Basis-Projekt README: `~/MyCloud/TOOLs/yabai-skhd-sbar/README.md`
- Migrations-Plan: [PLAN.md](PLAN.md)
