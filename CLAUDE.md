# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎯 QUICK START (für neue Claude-Instanzen)

**VOR JEDER CONFIG-ÄNDERUNG:**
```bash
./scripts/verify-symlinks.sh  # MUSS ✅ sein! Verhindert Config-Desync
```

**Aerospace Config ändern:**
```bash
vim configs/aerospace.toml
aerospace reload-config
```

**Sketchybar Config ändern:**
```bash
vim configs/sketchybar/init.lua
./scripts/refresh-aerospace-sketchy.sh  # Soft-Reload (EMPFOHLEN)
# Fallback: ./scripts/restart_services.sh
```

**Troubleshooting Quick-Check:**
```bash
ps aux | grep -E '[s]ketchybar' | wc -l  # Sollte 2 sein
aerospace list-workspaces --all          # Q W E R T A S D F G
sketchybar --query bar | head -20        # Prüfe Items
ls -la /tmp/sketchybar*.lock 2>/dev/null # Lock-Files prüfen
```

**Vollständige Diagnostics:** `docs/TROUBLESHOOTING.md`

---

## Projekt-Übersicht

**Production-ready macOS Window Management Setup**
- **Window Manager:** Aerospace 0.19.2-Beta (i3-inspiriert, kein SIP-Disable!)
- **Status Bar:** Sketchybar (Lua-basiert, event-driven Aerospace-Integration)
- **Key Remapping:** Karabiner-Elements (CapsLock → Hyper)
- **Workspaces:** QWERTZ-Layout (Q W E R T / A S D F G) + Overflow X/Y/Z
- **Migration:** Yabai+SKHD → Aerospace (67% weniger Scripts!)

**Basis-Projekt:** `~/MyCloud/TOOLs/yabai-skhd-sbar` (v2.7.2, Tag: v-yabai-final)

## Architektur-Konzepte

### System-Übersicht & Event-Flow

**Aerospace ↔ Sketchybar Integration (Event-Driven Architecture):**

```
┌─────────────────────────────────────────────────────────────────┐
│ USER ACTION                                                     │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┴────────────────────┐
         │                                         │
    Hyper+Q                              Window open/close/move
  (Workspace-Wechsel)                  (App starten/beenden)
         │                                         │
         ▼                                         ▼
┌─────────────────┐                    ┌──────────────────────┐
│   AEROSPACE     │                    │   SKETCHYBAR         │
│  workspace Q    │                    │  Window Observer     │
└─────────────────┘                    └──────────────────────┘
         │                                         │
         │ exec-on-workspace-change                │ window_created/
         │ (aerospace.toml:35-38)                  │ window_destroyed/
         │                                         │ routine (2s)
         ▼                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              SKETCHYBAR EVENT TRIGGERS                          │
│  --trigger aerospace_workspace_change FOCUSED_WORKSPACE=Q       │
│  --trigger workspace_force_refresh                              │
└─────────────────────────────────────────────────────────────────┘
         │                                         │
         ▼                                         ▼
┌─────────────────┐                    ┌──────────────────────┐
│   HANDLER 1     │                    │    HANDLER 2         │
│  spaces.lua:304 │                    │  spaces.lua:368      │
│  (Instant)      │                    │  (150ms Delay!)      │
└─────────────────┘                    └──────────────────────┘
         │                                         │
         └────────────────┬────────────────────────┘
                          ▼
        ┌───────────────────────────────────────┐
        │   AEROSPACE BATCH QUERY SYSTEM        │
        │   aerospace_batch.lua:query_with_     │
        │   monitors() - 4 Parallel Queries:    │
        │   1. list-monitors                    │
        │   2. list-workspaces --all            │
        │   3. list-workspaces --focused        │
        │   4. list-windows --all               │
        │   → 1s Cache, Completion Callback     │
        └───────────────────────────────────────┘
                          │
         ┌────────────────┴────────────────┐
         ▼                                 ▼
┌──────────────────┐           ┌────────────────────────┐
│ WORKSPACE        │           │ APP-ICONS UPDATE       │
│ DISCOVERY        │           │ (spaces.lua:417-530)   │
│ (spaces.lua:387) │           │ - app_icons.lua lookup │
│ - QWERTZ always  │           │ - SF-Symbols rendering │
│ - Numerisch      │           │ - :obsidian: :code:    │
│   on-demand      │           └────────────────────────┘
└──────────────────┘
         │
         ▼
┌──────────────────┐
│ MONITOR-BASED    │
│ GRUPPIERUNG      │
│ (spaces.lua:494) │
│ [Q W E R T]  │   │
│ [Q W E R T]      │
│  Mon 2   Mon 1   │
└──────────────────┘
         │
         ▼
┌──────────────────┐
│ SOFT-DELETE      │
│ drawing=off      │
│ (leere WS)       │
└──────────────────┘
```

**CRITICAL:**
- **Handler 1** (User-WS-Wechsel): Komplettes Rebuild instant
- **Handler 2** (Window-Events): 150ms Delay für Aerospace State-Update, dann lightweight Icon-Updates
- **Logic in beiden MUSS identisch sein!** (App-Icon-Generation, Monitor-Gruppierung)

### Lua-Module-Struktur (Sketchybar)

```
~/.config/sketchybar/
├─ sketchybarrc → init.lua (Entry Point)
│
├─ init.lua (655 Zeilen)
│  ├─ sbar.begin_config()
│  ├─ Events definieren (MUSS vor Items!)
│  │  ├─ claude_waiting_status
│  │  ├─ aerospace_workspace_change
│  │  └─ workspace_force_refresh
│  ├─ require("bar") → Bar-Konfiguration
│  ├─ require("default") → Default-Styles
│  ├─ Performance-Module init:
│  │  ├─ update_manager:init()
│  │  └─ aerospace_batch:init()
│  ├─ require("items") → Alle Items laden
│  └─ sbar.event_loop()
│
├─ items/
│  ├─ init.lua → Items-Loader
│  ├─ apple.lua → Apple-Logo + Doppelklick Handler
│  ├─ spaces.lua (655 Zeilen!) → Workspaces, 2 Event-Handler
│  ├─ menus.lua → Dropdown-Menüs
│  └─ widgets/
│     ├─ init.lua (11 Zeilen)
│     ├─ claude_notifier.lua (102 Zeilen)
│     ├─ myping_toggle.lua (95 Zeilen)
│     ├─ cpu.lua (310 Zeilen)
│     ├─ memory.lua (341 Zeilen)
│     ├─ battery.lua (228 Zeilen)
│     ├─ volume.lua (308 Zeilen)
│     ├─ network.lua (415 Zeilen)
│     ├─ disk.lua (382 Zeilen)
│     └─ system_status.lua (251 Zeilen)
│
└─ helpers/
   ├─ aerospace_batch.lua → Query-Optimierung (4 parallele Queries, 1s Cache)
   ├─ app_icons.lua → SF-Symbols Mapping (300+ Apps)
   ├─ json.lua → JSON Parser
   ├─ update_manager.lua → Centralized Updates
   └─ default_font.lua → Font-Definitionen
```

**Module-Statistik (~3700 Zeilen total):**

**Core** (7 Files, 303 Zeilen): init.lua (35), bar.lua (21), bar_config.lua (24), colors.lua (30), settings.lua (26), default.lua (54), icons.lua (113)

**Helpers** (6 Files, 868 Zeilen): aerospace_batch.lua (201), update_manager.lua (275), app_icons.lua (313), json.lua (62), default_font.lua (13), init.lua (4)

**Items** (7 Files, 974 Zeilen): spaces.lua (709 ⭐⭐⭐), media.lua (118), menus.lua (72), apple.lua (47), notch.lua (15), init.lua (13)

**Widgets** (10 Files, 2443 Zeilen): network.lua (415), disk.lua (382), memory.lua (341), cpu.lua (310), volume.lua (308), system_status.lua (251), battery.lua (228), claude_notifier.lua (102), myping_toggle.lua (95), init.lua (11)

### Monitor-basierte Workspace-Gruppierung (Feature seit 2025-11-14)

**Sketchybar Order folgt Monitor-Gruppierung:**

```
Sketchybar (bottom):
Apple-Logo | [Q W E R T A S D F G]  │  [Q W E R T A S D F G] | Widgets
             ^^^^ Monitor 2 ^^^^        ^^^^ Monitor 1 ^^^^
             (Built-in Laptop)          (External Display)
```

**Navigation (Hyper+N/M) folgt DIESER Reihenfolge!**
- `workspace-next.sh` / `workspace-prev.sh` nutzen GLEICHE Logic wie Sketchybar
- Monitor-Wechsel (Workspace → anderer Monitor) triggert Reorder
- Topology-Detection: `last_monitor_assignments` (spaces.lua:122)
- Queue-based Debounce: `reorder_pending` (spaces.lua:358)

**Implementation:** spaces.lua:494-546 (Monitor-gruppiertes Reorder)

### Config-Struktur (SYMLINK-basiert!)

**Aerospace:** `~/.aerospace.toml` → `configs/aerospace.toml`
- 260+ Zeilen TOML
- Workspaces: Q W E R T A S D F G + Overflow X/Y/Z
- Shortcuts: Hyper (ctrl-alt-shift) + Hyper+ (ctrl-alt-shift-cmd)
- `exec-on-workspace-change` triggert Sketchybar
- Window Rules: Floating für System-Apps

**Sketchybar:** `~/.config/sketchybar` → `configs/sketchybar/`
- Entry: `sketchybarrc` → `init.lua`
- Aerospace Integration: `helpers/aerospace_batch.lua`, `items/spaces.lua`
- Events: `aerospace_workspace_change` (User-WS-Wechsel) + `workspace_force_refresh` (Window-Events)
- Layout: Apple-Logo | Q W E R T | A S D F G | X/Y/Z | Widgets

**⚠️ CRITICAL:** Configs MÜSSEN Symlinks sein! Siehe "Kritische Lessons Learned" #1.

### Aerospace vs macOS Spaces

**Aerospace nutzt virtuelle Workspaces, NICHT Mission Control Spaces:**
- Alle Fenster in EINEM macOS Space (meist Space 1)
- Mission Control zeigt nur 1 Space
- Aerospace versteckt/zeigt Fenster intern
- Sketchybar Items als `"item"` Type (NICHT `"space"`!)

### QWERTZ Workspace-System

```
Obere Reihe:  Q  W  E  R  T   → Navigation/Kommunikation (Obsidian, Citrix, Mail, Terminal)
Untere Reihe: A  S  D  F  G   → Builder/Produktivität (VS Code, Safari, Finder)
Overflow:     X  Y  Z         → Dynamisch bei Multi-Monitor

NIEMALS numerische Workspaces (1,2,3...) verwenden! Aerospace erstellt jeden Namen sofort.
```

## Wichtigste Scripts

### System Health & Config
```bash
./scripts/verify-symlinks.sh            # Config Symlink Check (VOR jedem Edit!)
./scripts/refresh-aerospace-sketchy.sh  # Soft-Reload (EMPFOHLEN)
./scripts/restart_services.sh           # Force-Restart mit Zombie-Guards
```

### Layouts & Windows
```bash
./scripts/layout-toggle.sh              # Hyper + B (Tiles Horizontal ↔ Vertical)
./scripts/layout-accordion-toggle.sh    # Hyper + Comma
./scripts/balance-toggle.sh             # Hyper+ + B
./scripts/focus-circular.sh             # Hyper + J/L (wrap-around)
./scripts/center-mouse.sh               # Mouse-Follows-Focus (JXA)
```

### Workspace Navigation
```bash
./scripts/workspace-next.sh             # Hyper + M
./scripts/workspace-prev.sh             # Hyper + N
./scripts/move-next-follow.sh           # Hyper+ + M
./scripts/move-prev-follow.sh           # Hyper+ + N
./scripts/delete-current-workspace.sh   # Workspace löschen (falls nötig)
./scripts/focus-monitor-and-center.sh   # Hyper + U/P (Monitor wechseln + Mouse center)
```

**Vollständige Dokumentation:** `scripts/README.md`

## Workflows & Features

### Mouse-Follows-Focus (JXA-basiert)

**Problem:** Aerospace hat KEINE window-x/y Variablen (anders als Yabai)

**Lösung:** `center-mouse.sh` nutzt JXA (JavaScript for Automation):

```javascript
// JXA Script (center-mouse.sh):
const app = Application('System Events').applicationProcesses.whose({ frontmost: true })[0];
const win = app.windows[0];
const pos = win.position();
const size = win.size();
const centerX = pos[0] + size[0] / 2;
const centerY = pos[1] + size[1] / 2;
// → cliclick m:X,Y (primary) oder Swift CGWarpMouseCursorPosition (fallback)
```

**Integration:**
- Alle Focus-Commands: `exec-and-forget center-mouse.sh` (aerospace.toml:72-75, 93-104)
- Workspace-Wechsel: Automatisch bei Hyper+Q/W/E/R/T/A/S/D/F/G
- Monitor-Wechsel: `focus-monitor-and-center.sh` (Hyper+U/P)

**Fallback:** Falls JXA fehlschlägt → Swift CGWarpMouseCursorPosition

### Widget-System (Sketchybar)

**Location:** `configs/sketchybar/items/widgets/` (10 Widgets, 2443 Zeilen)

**Übersicht:**

1. **claude_notifier.lua** (102 Zeilen)
   - Zeigt Claude Code Status in Sketchybar
   - Trigger: `claude_waiting_status` Event
   - Icon: ⚡ (aktiv) / 💤 (idle)
   - Script: `scripts/claude-notify-hook.sh`

2. **myping_toggle.lua** (95 Zeilen)
   - Toggle für MyPing Skill (On/Off)
   - Script: `scripts/toggle-myping-skill.sh`
   - State-File: `/tmp/myping-skill-active`

3. **cpu.lua** (310 Zeilen)
   - CPU-Auslastung (user + system %)
   - Polling: 2s via update_manager
   - Fallback: Direct `top` Query
   - **Fix 2025-11-15:** Jetzt user+sys statt nur user

4. **memory.lua** (341 Zeilen)
   - RAM-Auslastung via `vm_stat`
   - Berechnung: active/(active+free)*100
   - Farb-Gradient: grün → gelb → rot

5. **battery.lua** (228 Zeilen)
   - Batterie-Status (% + Charging)
   - Icon wechselt je nach Level
   - Warnung bei <20%

6. **volume.lua** (308 Zeilen)
   - System-Volume Control
   - Click: Mute Toggle
   - Scroll: Volume ±5%

7. **network.lua** (415 Zeilen)
   - Netzwerk-Status (WiFi/Ethernet)
   - Upload/Download Raten
   - Connection-Quality Indicator

8. **disk.lua** (382 Zeilen)
   - Disk-Usage (/ Partition)
   - `df -h` Parsing
   - Warnung bei >90%

9. **system_status.lua** (251 Zeilen)
   - Kombinierter System-Überblick
   - CPU + Memory + Disk in einem Item

10. **init.lua** (11 Zeilen)
    - Widget-Loader
    - Lädt alle Widgets via `require()`

**Integration:**
- Zentrale Updates via `update_manager.lua` (batch_cmd)
- Polling alle 2s (configurable)
- Event-basierte Updates für Claude/MyPing

### Apple-Logo Klick (Pause/Resume Toggle)

**Trigger:** Einzelklick auf Apple-Logo (Sketchybar)

**Funktion:** Toggelt Aerospace zwischen "aktiv" und "pausiert"

**State-File:** `/tmp/aerospace-paused-state`
- Existiert = Aerospace pausiert
- Fehlt = Aerospace aktiv

**Icon-Farben:**
- Weiß (`0xffffffff`) = Aktiv (Window-Management läuft)
- Dunkelgrau (`0xff6e6e6e`) = Pausiert (Window-Management gestoppt)

**⚠️ WICHTIG - Aerospace-Befehl (versionsabhängig, geprüft 2025-11-15):**
```bash
# Aerospace ≤ 0.19.x (AKTUELL v0.19.2-Beta):
aerospace enable on/off

# Aerospace ≥ 0.20 (bei Upgrade umstellen!):
aerospace managed on/off

# Script mit TODO-Kommentaren vorbereitet:
# configs/sketchybar/plugins/apple_click_handler.sh
```

**Flow beim Pausieren:**
1. `aerospace enable off` (Window-Management stoppen)
2. `killall borders` (Borders beenden)
3. State-File erstellen
4. Notification "⏸️ AeroSpace Paused"
5. Icon dunkelgrau setzen

**Flow beim Reaktivieren:**
1. `aerospace enable on` (Window-Management starten)
2. 0.3s Wartezeit
3. Borders restart (falls vorhanden)
4. `refresh-aerospace-sketchy.sh` ausführen
5. State-File löschen
6. Notification "▶️ AeroSpace Active"
7. Icon weiß setzen

**Script:** `~/.config/sketchybar/plugins/apple_click_handler.sh`

**Sync nach Sketchybar-Restart:** apple.lua prüft State-File bei `aerospace_workspace_change` Event und setzt Icon-Farbe entsprechend.

### Apple-Logo Doppelklick (Soft-Refresh)

**Trigger:** Doppelklick auf Apple-Logo (Sketchybar) - **NICHT MEHR AKTIV**

**Script:** `configs/sketchybar/items/apple.lua` → `scripts/apple_click_handler.sh`

**Flow:**
```bash
1. verify-symlinks.sh          # Config-Check (verhindert Desync!)
2. aerospace reload-config     # TOML neu laden
3. start-borders.sh            # JankyBorders restart (optional)
4. sketchybar --reload         # Sanfter Reload (KEIN Kill!)
5. --trigger aerospace_workspace_change
6. --trigger workspace_force_refresh
```

**Vorteil vs `restart_services.sh`:**
- KEIN Force-Kill → Keine Zombie-Prozesse
- Sanfter Reload → Keine Unterbrechung
- Automatischer Symlink-Check

**Fallback:** `./scripts/restart_services.sh` (Force-Kill + Zombie-Guards)

### Window-Navigation Patterns

**1. Circular Navigation (Hyper+J/L):**
```bash
# focus-circular.sh [left|right]
# Wrap-around: letztes → erstes, erstes → letztes
# Nutzt Window-IDs Array, Modulo-Arithmetik: (index + 1) % total
aerospace list-windows --workspace focused --format %{window-id}
# → Array, find current, (index ± 1) % length, aerospace focus --window-id
```

**2. Directional Navigation (Hyper+Pfeile):**
```bash
# focus-and-center.sh [up|down|left|right]
# KEIN Wrap: Stoppt an Grenzen
# Nutzt aerospace focus [direction]
aerospace focus up/down/left/right
./center-mouse.sh  # Mouse-Center
```

**Wann welches?**
- **J/L:** Horizontales Cycling (Karussell, wrap-around)
- **Pfeile:** Directional Grid-Navigation (stoppt an Grenzen)

### Multi-Monitor Workspace-Flow

**Aerospace Workspace-Monitor-Binding:**
- Workspaces sind NICHT an Monitor gebunden!
- Workspace kann zwischen Monitoren verschoben werden
- Jeder Monitor zeigt EINE Workspace gleichzeitig

**Shortcuts:**
- **Hyper+O:** Workspace → next Monitor verschieben (HAUPTFUNKTION!)
- **Hyper+U/P:** Focus zwischen Monitoren wechseln (+ mouse center)
- **Hyper+I:** Window → next Monitor verschieben (Smart mit X/Y/Z)
- **Hyper++U/P:** Workspace → prev/next Monitor + Sketchybar-Refresh

**Overflow-Workspaces X/Y/Z:**
- Automatisch erstellt bei Multi-Monitor (wenn Ziel-Monitor leer)
- Sortierung nach QWERTZ-Order in Sketchybar
- Script: `move-window-to-monitor.sh` (Smart Assignment)

### Window Rules System

**Pattern-Matching (aerospace.toml [[on-window-detected]]):**

```toml
# Bundle-ID (präzise):
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'

# App-Name Regex:
[[on-window-detected]]
if.app-name-regex-substring = 'Finder'
run = 'layout floating'

# Window-Title Regex:
[[on-window-detected]]
if.app-id = 'com.raycast.macos'
if.window-title-regex-substring = 'Settings'
run = 'layout floating'

# Auto-Workspace-Assignment:
[[on-window-detected]]
if.app-id = 'md.obsidian'
run = 'move-node-to-workspace Q'
```

**Get App-ID:** `osascript -e 'id of app "AppName"'` oder `./scripts/get-app-id.sh`

**Vollständige Dokumentation:** `scripts/README.md`

## Code-Patterns & Best Practices

### Aerospace Commands

**Workspace Navigation:**
```bash
aerospace workspace Q                    # Zu QWERTZ-Workspace wechseln
aerospace list-workspaces --all          # Alle Workspaces (inkl. hidden)
aerospace list-windows --workspace Q     # Windows in Workspace Q
```

**Window Management:**
```bash
aerospace move left/right/up/down              # Fenster innerhalb Workspace bewegen
aerospace move-node-to-workspace A             # Zu Workspace A verschieben
aerospace move-node-to-monitor next            # Zu anderem Monitor
aerospace focus left/right/up/down             # Fokus ändern
```

**Layouts:**
```bash
aerospace layout tiles                   # Tiles Layout (nebeneinander)
aerospace layout accordion               # Accordion Layout (übereinander)
aerospace layout floating                # Floating Layout
aerospace balance-sizes                  # Fenster-Größen ausgleichen
```

**Config & Debugging:**
```bash
aerospace reload-config                  # Config neu laden (TOML)
aerospace list-monitors                  # Alle Monitore
aerospace debug-windows                  # Window-Tree Debug
```

**Wann Script vs Command?**
- **Aerospace Command:** Einzelne Operation (focus, move, layout)
- **Script:** Mehrere Steps, Logic, Mouse-Center, Error-Handling

### Sketchybar Event-Architecture

**2-Handler-Pattern (instant updates):**

**Handler 1:** `aerospace_workspace_change` (User wechselt Workspace)
- Triggered von Aerospace `exec-on-workspace-change` (aerospace.toml:35-38)
- Komplettes Rebuild: Discovery, Items, Icons
- Implementation: spaces.lua:304-367
- Instant execution (keine Delays!)

**Handler 2:** `workspace_force_refresh` (Window open/close/move)
- Triggered von Sketchybar `window_created`, `window_destroyed`, `routine` (2s)
- **150ms Delay für Aerospace State-Update!** (spaces.lua:369)
- Nur Icon-Updates (lightweight, kein Discovery)
- Implementation: spaces.lua:368-602

**CRITICAL:** Logic in beiden Handlern MUSS identisch sein (App-Icon-Generation!)

**Aerospace Batch Query System:**
```lua
-- aerospace_batch.lua - 4 parallele Queries:
aerospace_batch:query_with_monitors(function(data)
  -- 1. list-monitors → Monitor-Topology
  -- 2. list-workspaces --all → Alle WS mit Monitor-Assignment
  -- 3. list-workspaces --focused → Aktuell fokussierte WS
  -- 4. list-windows --all → Alle Fenster mit App-Namen

  -- Completion-Callback wenn alle 4 fertig
  -- 1s Cache (vermeidet redundante Queries)
end)
```

**Dynamic Workspace Discovery & Soft-Delete:**
```lua
-- Discovery (spaces.lua:387-473):
-- QWERTZ/XYZ: Immer erstellt (Q W E R T A S D F G X Y Z)
-- Numerische WS: Nur wenn Fenster vorhanden
-- create_workspace_item() on-demand

-- Soft-Delete (spaces.lua:474-492):
local should_show = (has_windows or is_focused)
if not should_show then
  sbar.set(space_item, { drawing = "off" })  -- Verstecken, nicht löschen!
end
-- KEINE Exemption für QWERTZ mehr! (geändert 2025-11-14)
```

**App-Icons SF-Symbols Mapping:**
```lua
-- app_icons.lua - 300+ App-Mappings:
local app_icons = {
  ["Obsidian"] = ":obsidian:",        -- Tropfen
  ["Code"] = ":code:",                 -- Spirale
  ["Claude"] = ":claude:",             -- Stern
  ["Safari"] = ":safari:",             -- Kompass
  ["Default"] = ":default:",           -- Fragezeichen
}

-- Integration in spaces.lua:417-530:
for app, count in pairs(apps) do
  local icon = app_icons[app] or app_icons["Default"]
  icon_line = icon_line .. icon
  if count > 1 then icon_line = icon_line .. count end
end
```

**Performance:**
- 0% CPU idle, ~1% CPU bei Window-Changes
- Events trigger instant, Polling (2s) nur Fallback
- 1s Cache für Aerospace-Queries

### Workspace-Naming Convention

**CRITICAL: NIEMALS numerische Workspaces verwenden!**

```bash
# ❌ FALSCH - Erstellt ungewollte numerische Workspace
aerospace workspace 1

# ✅ RICHTIG - QWERTZ-System
aerospace workspace Q  # Erste Workspace
aerospace workspace G  # Letzte Haupt-Workspace

# Fallbacks in Scripts: Q (erste), G (letzte), X/Y/Z (overflow)
```

**Grund:** Aerospace erstellt jeden Namen SOFORT → `workspace 1` erstellt "1"

## Kritische Lessons Learned

### 0. Sketchybar Lock-File Issues

**Symptom:** `sketchybar: could not acquire lock-file... already running?`

**Ursache:** Zombie Sketchybar-Prozess oder Lock-File bleibt nach Crash

**Schnelle Lösung:**
```bash
killall sketchybar
rm -f /tmp/sketchybar_*.lock 2>/dev/null
sketchybar
```

**Bessere Lösung:** `./scripts/restart_services.sh` (enthält Lock-File-Cleanup)

**Prevention:** Nutze immer `refresh-aerospace-sketchy.sh` statt manueller Restarts

### 1. Config-Desynchronisation (TOP PRIORITY!)

**Symptom:** Config-Änderungen wirken nicht
**Cause:** Symlink fehlt! `~/.aerospace.toml` ist normale Datei statt Link

**Prevention:**
```bash
./scripts/verify-symlinks.sh  # VOR jedem Edit!
```

**Fix:**
```bash
rm ~/.aerospace.toml ~/.config/sketchybar
ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml ~/.aerospace.toml
ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/sketchybar ~/.config/sketchybar
```

### 2. Sketchybar Zombie-Prozesse & Lock-Files

**Symptom:** Workspaces nicht klickbar, mehrere Lua-Prozesse, "could not acquire lock-file"
**Cause:** Mehrfache Restart-Versuche ohne Sleep, Zombie-Prozesse, verwaiste Lock-Files

**Solution:**
```bash
./scripts/refresh-aerospace-sketchy.sh  # Soft-Reload (EMPFOHLEN)
# ODER
./scripts/restart_services.sh           # Force mit Zombie-Guards + Lock-Cleanup
# ODER (manuell bei Lock-Issues)
killall sketchybar && rm -f /tmp/sketchybar_*.lock && sketchybar
```

**Details:** `docs/TROUBLESHOOTING.md`

### 3. Aerospace-Spezifika

**Virtual Workspaces ≠ macOS Spaces:**
- Alle Fenster in EINEM macOS Space
- Sketchybar Items als `"item"` Type (NICHT `"space"`!)
- "Displays have separate Spaces" MUSS ON sein

**Nach Aerospace-Update:**
- Accessibility Permission OFF/ON togglen

**Window Manager Konflikte:**
- NIEMALS Yabai + Aerospace gleichzeitig
- Clean Start: Yabai stoppen → Reboot → Aerospace

### 4. Event-Driven Architecture

**App-Icons Instant-Update:**
- 2 Handler: `aerospace_workspace_change` + `workspace_force_refresh`
- 150ms Delay für Aerospace State-Update
- Logic in beiden MUSS identisch sein!

**Performance:**
- Events trigger instant, Polling (2s) nur Fallback
- 0% CPU idle, ~1% bei Window-Changes

## Git & Rollback

**Tags:**
- `v-yabai-final` - Letzter Yabai-Stand (in ~/MyCloud/TOOLs/yabai-skhd-sbar)

**⚠️ NIEMALS pushen ohne User-Anweisung!**

**Migration Status:** Abgeschlossen (Production-ready seit 2025-11-12). Rollback nicht mehr verfügbar (Yabai deinstalliert).

## Dokumentation & Ressourcen

**Projekt-Docs:**
- `README.md` - Setup, Installation, Troubleshooting Quick-Ref
- `docs/TROUBLESHOOTING.md` - **WICHTIGSTE RESOURCE** für Problemlösungen
- `docs/PLAN.md` - Migrations-Plan (in scripts/ToDos.md verschoben)
- `SHORTCUTS.md` - Yabai→Aerospace Transition Cheat Sheet
- `scripts/README.md` - Scripts-Übersicht

**Externe Docs:**
- **Aerospace:** https://nikitabobko.github.io/AeroSpace/guide
- **Sketchybar:** https://felixkratz.github.io/SketchyBar/

## Migration Status

**Status:** ✅ ABGESCHLOSSEN - Production-ready seit 2025-11-12
**Aerospace >> Yabai Performance** (User: "unglaublich performant")
**Scripts-Reduktion:** 18 → 6 Core Scripts (67% weniger!)
**Migrations-Plan:** `docs/archive/PLAN.md` (abgeschlossen 2025-11-12)
**Aktuelle TODOs:** Siehe `scripts/ToDos.md`

## Known Issues & Maintenance

**Aerospace Quirks:**
- Versteckte Fenster rendern weiter → Battery-Drain (Design-Decision)
- Mission Control zeigt nur 1 Space (virtuelle Workspaces)
- "Displays have separate Spaces" MUSS ON sein
- **Aerospace-Befehle versionsabhängig:**
  - **v0.19.x und früher:** `aerospace enable on/off/toggle` (AKTUELL v0.19.2-Beta)
  - **v0.20 und später:** `aerospace managed on/off/toggle`
  - **Bei Upgrade auf v0.20+:** `apple_click_handler.sh` anpassen (`enable` → `managed`)

**Sketchybar:**
- Config-Änderungen: Soft-Reload nutzen (`refresh-aerospace-sketchy.sh`)
- Zombie-Check: `ps aux | grep -E '[s]ketchybar' | wc -l` sollte 2 sein

**Maintenance:**
- Nach Aerospace-Updates: Accessibility Permission OFF/ON togglen
- **NIEMALS** Configs in `~/` direkt editieren (nur via Symlinks in `configs/`!)
