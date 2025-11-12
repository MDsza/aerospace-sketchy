# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Projekt-Übersicht

**Status:** Phase 5 ABGESCHLOSSEN ✅ - Production-ready Aerospace-Setup
**Migration:** Yabai+SKHD → Aerospace+Sketchybar

**Basis-Projekt:** `~/MyCloud/TOOLs/yabai-skhd-sbar` (v2.7.2, archiviert als v-yabai-final)

### Technologie-Stack

**Aktuelles Setup (Production):**
- **Window Manager:** Aerospace 0.19.2-Beta (i3-inspiriert, kein SIP-Disable!)
- **Status Bar:** Sketchybar (Lua-basiert, Aerospace-integriert)
- **Key Remapping:** Karabiner-Elements (CapsLock → Hyper)
- **Config:** TOML (~/.aerospace.toml)
- **Workspaces:** Fixes QWERTZ-Layout (Q W E R T / A S D F G) + optionale Overflow-Spaces X/Y/Z

**Ersetzte Komponenten:**
- ~~Yabai (BSP Window Manager)~~ → Aerospace
- ~~SKHD (Keyboard Daemon)~~ → Aerospace built-in
- Karabiner BEIBEHALTEN (unverzichtbar für Hyper-Key)

## Architektur & Config-Management

### Zentrale Configs

**Aerospace Config:** `~/.aerospace.toml` (symlinked von `configs/aerospace.toml`)
- ~260 Zeilen TOML
- Workspaces: Q W E R T A S D F G (feste QWERTZ-Matrix) + Overflow X/Y/Z
- Shortcuts: Hyper (ctrl-alt-shift) + Hyper+ (ctrl-alt-shift-cmd)
- Sketchybar Integration: `exec-on-workspace-change` Trigger + Mauszentrierung
- Window Rules: Floating für System-Apps (Settings, Raycast, etc.)

**Sketchybar Config:** `~/.config/sketchybar/` (symlinked von `configs/sketchybar/`)
- Lua-basiert: `sketchybarrc` → `init.lua`
- **Aerospace Integration:**
  - `helpers/aerospace_batch.lua` - CLI-Wrapper für Queries
  - `items/spaces.lua` - Workspace-Items (NICHT native Space-Type!)
  - Events: `aerospace_workspace_change` + `workspace_force_refresh` (Update der App-Icons bei Fenster-Änderungen)
- **Fixed Order:** Q W E R T | A S D F G (linke Hand, mit Separator) → Overflow X/Y/Z
- **App-Icons:** Die Label-Zeile jeder Workspace-Kachel zeigt laufende Apps anhand der Glyphen aus `helpers/app_icons.lua`.
- Widgets: CPU, Memory, Network, Battery, Claude-Notifier (Front-App-Anzeige entfällt zugunsten der macOS-Menüleiste)

### Wichtige Architektur-Konzepte

**Aerospace virtuelle Workspaces vs macOS Spaces:**
- Alle Aerospace-Fenster in EINEM macOS Space (meist Space 1)
- Mission Control sieht nur 1 Space
- Aerospace versteckt/zeigt Fenster intern
- **WICHTIG:** Sketchybar Items als `"item"` Type, NICHT `"space"` Type!

**QWERTZ Workspace-System:**
```
Obere Reihe:  Q  W  E  R  T   (Navigation / Kommunikation)
Untere Reihe: A  S  D  F  G   (Builder / Files / Focus)
Overflow:     X  Y  Z         (dynamisch für Extra-Monitore)

Alle zehn Haupt-Workspaces existieren dauerhaft in Aerospace (keine macOS Spaces).
```

## Quick Start für neue Claude-Instanzen

### Daily Commands (am häufigsten benötigt)

```bash
# 1. Config-Änderung testen (IMMER ZUERST Symlink-Check!)
./scripts/verify-symlinks.sh         # ✅ MUSS ✅ sein!
vim configs/aerospace.toml
aerospace reload-config

# 2. Sketchybar Config ändern
vim configs/sketchybar/init.lua      # oder items/spaces.lua etc.
./scripts/refresh-aerospace-sketchy.sh  # Soft-Reload (EMPFOHLEN)
# ODER als Fallback bei hartem Problem:
./scripts/restart_services.sh          # Force-Restart

# 3. Scripts entwickeln/testen
vim scripts/my-new-script.sh
chmod +x scripts/my-new-script.sh
./scripts/my-new-script.sh

# 4. Troubleshooting
ps aux | grep -E '[s]ketchybar' | wc -l  # Sollte 2 sein
aerospace list-workspaces --all          # Q W E R T A S D F G
sketchybar --query bar | head -20        # Prüfe Items
```

## Häufige Entwicklungsaufgaben

### Config-Änderungen testen

**🔴 CRITICAL: Symlink-Check ZUERST!**

```bash
# IMMER ZUERST prüfen ob Symlinks korrekt sind!
./scripts/verify-symlinks.sh
# Erwartung: ✅ Alle Checks passed
# Falls FEHLER: Script zeigt Fix-Commands

# Dann erst editieren:
vim configs/aerospace.toml
aerospace reload-config

# Sketchybar Config ändern → Soft-Reload
vim configs/sketchybar/init.lua
./scripts/refresh-aerospace-sketchy.sh
# Lädt Config neu OHNE Prozess-Kill

# Prüfe ob sauber (2 Prozesse erwartet):
ps aux | grep -E '[s]ketchybar' | wc -l  # Sollte 2 sein

# Test Workspace-Wechsel triggert Sketchybar:
aerospace workspace E
# → Erwartung: Highlighting sofort, App-Icons sofort
```

### Scripts entwickeln/testen

```bash
# Wichtigste Scripts (Production):
./scripts/refresh-aerospace-sketchy.sh  # Soft-Reload (EMPFOHLEN für Config-Änderungen)
./scripts/restart_services.sh           # Force-Restart (Fallback bei Problemen)
./scripts/verify-symlinks.sh            # Prüft Config-Symlinks (VOR jeder Änderung!)

# Layout-Scripts:
./scripts/layout-tiles-horizontal.sh    # Hyper + H
./scripts/layout-tiles-vertical.sh      # Hyper + V
./scripts/layout-accordion-toggle.sh    # Hyper + K
./scripts/balance-toggle.sh             # Hyper+ + B

# Workspace Navigation:
./scripts/workspace-next.sh             # Hyper + L
./scripts/workspace-prev.sh             # Hyper + J
./scripts/move-next-follow.sh           # Hyper+ + L (mit Follow)
./scripts/move-prev-follow.sh           # Hyper+ + J (mit Follow)

# Utility:
./scripts/focus-and-center.sh           # Focus + Mouse-Center
./scripts/move-and-follow.sh            # Move + Follow
./scripts/center-mouse.sh               # Maus zum Fenster zentrieren
./scripts/get-app-id.sh                 # App Bundle-ID finden

# Alle Scripts dokumentiert in: scripts/README.md
```

### Sketchybar Troubleshooting

**Problem: Workspaces nicht klickbar / nicht highlighted**

✅ **GELÖST seit 2025-11-12** mit robustem `restart_services.sh`:
- Automatische Guards gegen Zombie-Lua-Prozesse
- Lock-File-Verification vor Restart
- 5s Timeout für sauberen Exit, Force-Kill bei Bedarf

**Quick Fix (falls doch Probleme):**
```bash
# Methode 1: Soft-Reload (EMPFOHLEN)
./scripts/refresh-aerospace-sketchy.sh

# Methode 2: Force-Restart (Fallback)
./scripts/restart_services.sh

# Methode 3: Manuell (nur bei hartnäckigen Problemen)
killall -9 sketchybar lua 2>/dev/null
sleep 2
brew services restart sketchybar
```

**Diagnostics:**
```bash
ps aux | grep -E '[s]ketchybar' | wc -l  # Erwartung: 2 (Daemon + Lua)
lsof /tmp/sketchybar_$USER.lock          # Prüft Lock-File
```

Details: `docs/TROUBLESHOOTING.md` + `docs/ZOMBIE-FIX.md`

## Code-Patterns & Best Practices

### Aerospace Commands (anstatt Yabai)

```bash
# Workspace Navigation
aerospace workspace 1           # Zu Workspace wechseln
aerospace list-workspaces       # Alle Workspaces auflisten
aerospace list-windows          # Windows mit IDs

# Window Management
aerospace move left/right/up/down              # Fenster bewegen
aerospace move-node-to-workspace C             # Zu Workspace C
aerospace move-node-to-monitor next            # Zu anderem Monitor
aerospace focus left/right/up/down             # Fokus ändern

# Layout
aerospace layout tiles          # Tiles Layout
aerospace layout accordion      # Accordion Layout
aerospace layout floating       # Floating Layout
aerospace balance-sizes         # Fenster-Größen ausgleichen

# Config
aerospace reload-config         # Config neu laden
```

### Sketchybar Integration (Event-basiert)

**2 Handler-Pattern (Production seit 2025-11-12):**

```toml
# In ~/.aerospace.toml - User Workspace-Wechsel
exec-on-workspace-change = [
  '/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

```lua
-- In Sketchybar Config - 2 separate Handler

-- 1. aerospace_workspace_change (User wechselt Workspace)
space_window_observer:subscribe("aerospace_workspace_change", function(env)
  aerospace_batch:refresh()
  aerospace_batch:query_with_monitors(function(batch_data)
    -- Komplettes Rebuild: Workspace-Discovery, Item-Creation, Icons
  end)
end)

-- 2. workspace_force_refresh (Window-Events)
space_window_observer:subscribe("window_created", function(env)
  sbar.trigger("workspace_force_refresh")
end)

space_window_observer:subscribe("workspace_force_refresh", function(env)
  aerospace_batch:refresh()
  sbar.delay(0.15, function()  -- 150ms für AeroSpace State-Update
    aerospace_batch:query_with_monitors(function(batch_data)
      -- Nur Icon-Updates (lightweight)
    end)
  end)
end)
```

**Wichtig:**
- Logic in beiden Handlern MUSS identisch sein (besonders App-Icon-Generation)
- 150ms Delay gibt AeroSpace Zeit für State-Update
- Polling (2s) als Fallback falls Events versagen

### Scripts: Aerospace-native Commands nutzen

**67% weniger Scripts durch Aerospace built-ins!**

NICHT mehr nötig (Aerospace native):
- ~~window-move-circular~~ → `aerospace move left/right/up/down`
- ~~fix-space-associations~~ → Virtuelle Workspaces brauchen kein Fix
- ~~space-explode~~ → Layout-System anders (tiles/accordion)

BEHALTEN (Aerospace-angepasst):
- `layout-toggle.sh` - Cycle durch Layouts (20 Zeilen vs 242 bei Yabai!)
- `balance-toggle.sh` - Nutzt `aerospace balance-sizes`

## Kritische Systemverhalten (Lessons Learned)

### 0. Config-Desynchronisation (HÄUFIGSTES PROBLEM!)
**SYMPTOM:** Config-Änderungen wirken nicht, `aerospace reload-config` bringt nichts
**ROOT CAUSE:** Symlink fehlt! `~/.aerospace.toml` ist normale Datei statt Link
**IMMER VOR EDIT PRÜFEN:**
```bash
ls -la ~/.aerospace.toml
# MUSS sein: lrwxr-xr-x ... -> .../configs/aerospace.toml
# Falls -rw-r--r--: Symlink fehlt!
```
**FIX:**
```bash
rm ~/.aerospace.toml
ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml ~/.aerospace.toml
```
**WARUM:** Nur Sketchybar wurde initial symlinked, Aerospace nur kopiert (siehe README vs CLAUDE.md Widerspruch)

### 1. Window Manager Konflikte
**NIEMALS Yabai + Aerospace gleichzeitig!**
- Beide WMs versuchen gleiche Fenster zu managen → Bildfehler/Flimmern
- **Lösung:** Yabai/SKHD stoppen → Neustart → Aerospace übernimmt clean

### 2. Sketchybar Lock-File-Problem (HÄUFIGSTE URSACHE!)
**Symptom:** Workspaces nicht klickbar, keine Highlights, mehrere Lua-Prozesse
**Ursache:** Mehrfache Restart-Versuche erzeugen Zombie-Prozesse
**IMMER verwenden:**
```bash
killall -9 sketchybar lua 2>/dev/null
sleep 2
brew services restart sketchybar
```

### 3. Displays Separate Spaces (ERFORDERLICH!)
**Aerospace MUSS haben:** "Displays have separate Spaces" = ON
- System Settings → Desktop & Dock → Mission Control
- Nach Toggle: System neu starten (ODER nur Toggle, Aerospace startet)

### 4. Accessibility nach Updates
**Nach jedem Aerospace-Update:** Permission OFF/ON togglen
- System Settings → Privacy & Security → Accessibility → Aerospace

### 5. Sketchybar Space-Type Fehler
**FALSCH:** `sbar.add("space", "space.1", { space = 1 })` - Bindet an macOS Space
**RICHTIG:** `sbar.add("item", "space.1", {})` - Normale Items
**Grund:** Aerospace virtuelle Workspaces ≠ macOS Spaces

## Rollback-Strategie

```bash
# Emergency Rollback (5 Minuten)
cd ~/MyCloud/TOOLs/aerospace+sketchy
./scripts/rollback-to-yabai.sh
# → Aerospace deaktiviert, Yabai/SKHD restored
```

## Projekt-Dokumentation

**Vollständige Dokumentation:**
- `README.md` - Setup-Anleitung, Installation, Rollback
- `PLAN.md` - Migrations-Plan Phase 0-8 (aktuell: Phase 5 ✅)
- `SHORTCUTS.md` - Transition Cheat Sheet (Yabai→Aerospace Mapping)
- `scripts/README.md` - Scripts-Übersicht und Testing
- `docs/TROUBLESHOOTING.md` - Detaillierte Problemlösungen

**Aerospace Docs:** https://nikitabobko.github.io/AeroSpace/guide
**Basis-Projekt:** ~/MyCloud/TOOLs/yabai-skhd-sbar (v2.7.2, Tag: v-yabai-final)

## Wichtigste Erkenntnisse (für zukünftige Claude-Instanzen)

**🎯 TOP PRIORITY CHECKS:**

```bash
# VOR JEDER CONFIG-ÄNDERUNG:
./scripts/verify-symlinks.sh  # MUSS ✅ sein!

# VOR JEDER SKETCHYBAR-ÄNDERUNG:
ps aux | grep -E '[s]ketchybar' | wc -l  # MUSS 2 sein!

# NACH CONFIG-ÄNDERUNGEN (Soft-Reload):
./scripts/refresh-aerospace-sketchy.sh
```

### Kritische Lessons Learned

1. **Config-Desynchronisation vermeiden (TOP PRIORITY!):**
   - `~/.aerospace.toml` MUSS Symlink sein → `./scripts/verify-symlinks.sh`
   - `~/.config/sketchybar` MUSS Symlink sein
   - **Häufigster Fehler:** Edit wirkt nicht weil kein Symlink!
   - **Fix:** Script zeigt automatisch Fix-Commands

2. **Aerospace ≠ Yabai Space-Model:**
   - Virtuelle Workspaces (NICHT Mission Control Spaces)
   - Sketchybar Items als `"item"` Type, NICHT `"space"` Type
   - Alle Fenster in EINEM macOS Space (meist Space 1)
   - Mission Control zeigt nur 1 Space

3. **Sketchybar Lua Zombies (✅ GELÖST 2025-11-12):**
   - **War Problem:** Lua workers überleben Restart → Lock-File gesperrt
   - **Lösung:** Robuste `restart_services.sh` + `refresh-aerospace-sketchy.sh`
   - **Jetzt:** Apple-Logo Doppelklick = zuverlässiger Soft-Reload
   - **Fallback:** `./scripts/restart_services.sh` mit Auto-Guards

4. **App-Icons Update Delay (✅ GELÖST 2025-11-12):**
   - **Problem:** Icons erschienen erst nach manuellem Workspace-Wechsel
   - **Root Cause:** `workspace_force_refresh` Event hatte keinen Handler
   - **Lösung:**
     - Handler für `workspace_force_refresh` mit 150ms AeroSpace-Delay
     - Events: `window_created`, `window_destroyed`, `routine` (2s polling)
     - Logic identisch zu `aerospace_workspace_change` (wichtig!)
   - **Jetzt:** Icons erscheinen instant bei Window-Changes (~150-300ms)

5. **Event-driven Architecture:**
   - 2 separate Handler: `aerospace_workspace_change` (User-WS-Wechsel) + `workspace_force_refresh` (Window-Events)
   - Events trigger instant, Polling (2s) nur Fallback
   - Performance: 0% CPU idle, ~1% bei Window-Changes

6. **Scripts-Reduktion 67%:**
   - Aerospace built-ins ersetzen viele Custom-Scripts
   - Balance-Toggle: 242 Zeilen → 20 Zeilen
   - Window-Movement: 3 Scripts → `aerospace move`
   - Insgesamt: 18 Scripts → 6 Core-Scripts

7. **Window Manager Konflikte:**
   - NIEMALS Yabai + Aerospace gleichzeitig!
   - Clean Start: Yabai/SKHD stoppen → Reboot → Aerospace

8. **Displays Separate Spaces:**
   - Aerospace benötigt "Displays have separate Spaces" = ON
   - Nach Toggle: Neustart (oder nur Toggle, Aerospace startet)

9. **Accessibility nach Updates:**
   - Nach jedem Aerospace-Update: Permission OFF/ON togglen
   - System Settings → Privacy & Security → Accessibility

**Performance:** Aerospace >> Yabai (User: "unglaublich performant")
**Status:** Production-ready seit Phase 5 (2025-11-11)
**Stability:** Zombie-Fix seit 2025-11-12 → Soft-Reload funktioniert zuverlässig
**App-Icons:** Instant-Update seit 2025-11-12 → Window-Events triggern sofort (150-300ms) 🎯
