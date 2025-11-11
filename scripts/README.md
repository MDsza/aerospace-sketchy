# Scripts für Aerospace Setup

**Migration von Yabai → Aerospace**

## Migrierte Scripts (Aerospace-kompatibel)

### Layout & Window Management

**`layout-toggle.sh`** - Layout-Wechsel für Aerospace
- Cycles: tiles horizontal → tiles vertical → accordion horizontal → accordion vertical → floating
- **Shortcut:** Hyper + Backslash (in ~/.aerospace.toml konfigurieren)
- **Usage:** `./layout-toggle.sh`

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
# Layout Toggle
ctrl-alt-shift-backslash = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/layout-toggle.sh'

# Balance Toggle
ctrl-alt-shift-o = 'exec-and-forget /Users/wolfgang/MyCloud/TOOLs/aerospace+sketchy/scripts/balance-toggle.sh'
```

## Vergleich: Yabai vs Aerospace Scripts

| Funktion | Yabai-Setup | Aerospace-Setup | Status |
|----------|-------------|-----------------|--------|
| Layout Toggle | BSP ↔ Stack (63 Zeilen) | tiles/accordion/floating (61 Zeilen) | ✅ Migriert |
| Balance Toggle | Floating Grid Logic (242 Zeilen!) | balance-sizes (20 Zeilen) | ✅ Vereinfacht |
| Window Movement | 3 Scripts (circular) | Aerospace built-in | ✅ Native |
| Space Management | 2 Scripts (fix/delete) | Nicht nötig | ✅ Obsolet |
| Sketchybar Reset | 1 Script | 1 Script (identisch) | ✅ Kopiert |

**Ergebnis:** Von 18 Scripts → 6 Scripts (67% Reduktion!)

## Testing

Alle Scripts getestet ✅:
- ✅ layout-toggle.sh funktioniert
- ✅ balance-toggle.sh funktioniert
- ✅ sketchybar-reset.sh funktioniert
- ✅ claude-notify-hook.sh funktioniert
- ✅ toggle-myping-skill.sh funktioniert
- ✅ rollback-to-yabai.sh funktioniert (Phase 1 getestet)
