# Scripts für Aerospace Setup

**Migration von Yabai → Aerospace**

## System Health & Verification

### **`verify-symlinks.sh`** - Config Symlink Checker
- Prüft ob Aerospace + Sketchybar Configs korrekt symlinked sind
- **IMMER vor Config-Edits ausführen!**
- Verhindert Config-Desynchronisation
- **Usage:** `./verify-symlinks.sh`
- Exit Code 0 = OK, 1 = Fehler gefunden

**Symptom wenn Symlink fehlt:**
- Config-Änderungen wirken nicht
- `aerospace reload-config` bringt nichts
- Edit in `configs/` wirkt nicht auf `~/.aerospace.toml`

## Migrierte Scripts (Aerospace-kompatibel)

### Layout & Window Management

**Layout Scripts (Tiles/Accordion)**
- `layout-toggle.sh` → Hyper + B (Tiles Horizontal ↔ Vertical Toggle)
- `layout-accordion-toggle.sh` → Hyper + Comma (Accordion ↔ letzter Tiles-Zustand)
- Floating erfolgt weiterhin über `Hyper+CMD+Enter`.

**`balance-toggle.sh`** - Fenster-Größen ausgleichen
- Nutzt Aerospace `balance-sizes` Command
- **Shortcut:** Hyper+ + B
- **Usage:** `./balance-toggle.sh`

**Window Focus Scripts (NEU 2025-11-12)**
- `focus-circular.sh` → Hyper + Left/Right - Circular navigation mit wrap-around
  - Beim letzten Fenster + Right → springt zu erstem
  - Beim ersten Fenster + Left → springt zu letztem
  - **Usage:** `./focus-circular.sh [left|right]`
- `focus-and-center.sh` → Hyper + Up/Down - Directional focus + mouse center
  - Stoppt an Grenzen (kein wrap)
  - **Usage:** `./focus-and-center.sh [up|down|left|right]`
- `focus-monitor-and-center.sh` → Hyper + U/P - Monitor focus + mouse center
  - **Usage:** `./focus-monitor-and-center.sh [prev|next]`

**Window Movement Scripts**
- `move-to-workspace.sh` → Move Window to Workspace (generic helper)
  - Verwendet von move-next-follow.sh / move-prev-follow.sh
  - **Usage:** `./move-to-workspace.sh Q` (bewegt zu Workspace Q + follow)

**Window Navigation (Keybindings geändert 2025-11-12)**
- Workspace Navigation: Hyper + **N**/M (war J/L)
- Window Focus: Hyper + **J**/L (war N/M)

### Sketchybar & System

**`sketchybar-reset.sh`** - Sketchybar Neustart (v3.0.0 Aerospace)
- Aerospace-aware (nutzt aerospace_workspace_change Event)
- Behebt Display-Issues
- **Updated 2025-11-12:** Kein Yabai socket ping mehr
- **Usage:** `./sketchybar-reset.sh`

**`refresh-aerospace-sketchy.sh`** - Soft-Reload (EMPFOHLEN)
- Lädt Sketchybar Config neu OHNE Prozess-Kill
- Nutzt `sketchybar --reload`
- **Usage:** `./refresh-aerospace-sketchy.sh`

**`restart_services.sh`** - Force-Restart mit Guards
- Force-Kill + Restart von Sketchybar
- Automatische Zombie-Process-Detection
- Lock-File-Verification
- **Usage:** `./restart_services.sh`

**`claude-notify-hook.sh`** - Claude Code Notification Hook
- **Updated 2025-11-12:** Nutzt Aerospace statt Yabai für Focus-Detection
- Funktioniert mit Sketchybar
- **Usage:** Automatisch via Claude Code

**`toggle-myping-skill.sh`** - MyPing Skill Toggle
- **Updated 2025-11-12:** Path korrigiert zu aerospace+sketchy
- **Usage:** `./toggle-myping-skill.sh`

**`center-mouse.sh`** - Mouse-Follows-Focus (v2.0 JXA)
- **Komplett neu geschrieben 2025-11-12:** Nutzt JXA (JavaScript for Automation)
- Liest Window-Geometrie von System Events (Aerospace hat keine window-x/y Variablen)
- Fallback: cliclick (primary) oder Swift/CoreGraphics
- **Usage:** `./center-mouse.sh`

## Obsolete Scripts (nicht migriert)

Diese Scripts aus dem Yabai-Setup sind **nicht mehr nötig** oder durch Aerospace-native Commands ersetzt:

### Aerospace-Native Ersetzt

- ❌ `window-move-next-circular.sh` → `aerospace move left/right/up/down`
- ❌ `window-move-prev-circular.sh` → `aerospace move left/right/up/down`
- ❌ `window-move-to-space.sh` → `aerospace move-node-to-workspace X`
- ❌ `window-move-display-circular.sh` → `aerospace move-node-to-monitor next/prev`

### Virtuelle Workspaces (nicht relevant)

- ❌ `fix-space-associations.sh` → Nicht nötig (Aerospace virtuelle Workspaces)
- ❌ `delete-empty-spaces.sh` → Nicht nötig (Aerospace virtuelle Workspaces)

### Layout-Logik Anders

- ❌ `space-explode-impl.sh` → Aerospace: Layout-System anders (tiles/accordion)
- ❌ `space-implode.sh` → Aerospace: Layout-System anders

### Neu zu Implementieren

- ❌ `window-move-to-new-space-maximize.sh` → TODO: Aerospace-Equivalent

## Shortcuts Integration

Füge diese Bindings in `~/.aerospace.toml` hinzu:

```toml
[mode.main.binding]
# Layouts
ctrl-alt-shift-h = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/layout-tiles-horizontal.sh'
ctrl-alt-shift-v = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/layout-tiles-vertical.sh'
ctrl-alt-shift-k = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/layout-accordion-toggle.sh'

# Balance Toggle
ctrl-alt-shift-o = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/balance-toggle.sh'
```

## Vergleich: Yabai vs Aerospace Scripts

| Funktion | Yabai-Setup | Aerospace-Setup | Status |
|----------|-------------|-----------------|--------|
| Layout (separate Scripts) | BSP ↔ Stack (63 Zeilen) | Tiles/Accordion (3 Skripte) | ✅ Migriert |
| Balance Toggle | Floating Grid Logic (242 Zeilen!) | balance-sizes (20 Zeilen) | ✅ Vereinfacht |
| Window Movement | 3 Scripts (circular) | Aerospace built-in | ✅ Native |
| Space Management | 2 Scripts (fix/delete) | Nicht nötig | ✅ Obsolet |
| Sketchybar Reset | 1 Script | 1 Script (identisch) | ✅ Kopiert |

**Ergebnis:** Von 18 Scripts → 6 Scripts (67% Reduktion!)

## Testing

Alle Scripts getestet ✅:
- ✅ layout-toggle.sh / layout-accordion-toggle.sh funktionieren
- ✅ balance-toggle.sh funktioniert
- ✅ sketchybar-reset.sh + refresh-aerospace-sketchy.sh funktionieren
- ✅ claude-notify-hook.sh funktioniert
- ✅ toggle-myping-skill.sh funktioniert
