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
- `layout-tiles-horizontal.sh` → Hyper + H
- `layout-tiles-vertical.sh` → Hyper + V
- `layout-accordion-toggle.sh` → Hyper + K (Accordion ↔ letzter Tiles-Zustand)
- Alle Skripte setzen den Layoutmodus direkt; Floating erfolgt weiterhin über `Hyper+CMD+Enter`.

**`balance-toggle.sh`** - Fenster-Größen ausgleichen
- Nutzt Aerospace `balance-sizes` Command
- **Shortcut:** Hyper + O (empfohlen)
- **Usage:** `./balance-toggle.sh`

### Sketchybar & System

**`sketchybar-reset.sh`** - Sketchybar Neustart
- Funktioniert identisch mit Aerospace
- Behebt Display-Issues
- **Usage:** `./sketchybar-reset.sh`

**`claude-notify-hook.sh`** - Claude Code Notification Hook
- Unverändert von Yabai-Setup
- Funktioniert mit Sketchybar
- **Usage:** Automatisch via Claude Code

**`toggle-myping-skill.sh`** - MyPing Skill Toggle
- Unverändert von Yabai-Setup
- **Usage:** `./toggle-myping-skill.sh`

### Rollback

**`rollback-to-yabai.sh`** - Emergency Rollback
- Deaktiviert Aerospace
- Aktiviert Yabai/SKHD
- Stellt alte Configs wieder her
- **Usage:** `./rollback-to-yabai.sh`

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
- ✅ layout-tiles-horizontal.sh / layout-tiles-vertical.sh / layout-accordion-toggle.sh funktionieren
- ✅ balance-toggle.sh funktioniert
- ✅ sketchybar-reset.sh + refresh-aerospace-sketchy.sh funktionieren
- ✅ claude-notify-hook.sh funktioniert
- ✅ toggle-myping-skill.sh funktioniert
- ✅ rollback-to-yabai.sh funktioniert (Phase 1 getestet)
