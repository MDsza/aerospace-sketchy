# SHORTCUTS TRANSITION GUIDE

Yabai+SKHD → Aerospace Migration

**Modifier-Keys bleiben GLEICH:**
- **Hyper** = ⌃⌥⇧ (CapsLock via Karabiner)
- **Hyper+** = ⌃⌥⇧⌘ (CapsLock+CMD via Karabiner)

---

## FENSTER-MANAGEMENT

### Focus & Swap

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Fenster Links fokussieren | Hyper + ← | Hyper + ← | ✅ GLEICH |
| Fenster Rechts fokussieren | Hyper + → | Hyper + → | ✅ GLEICH |
| Fenster Oben fokussieren | Hyper + ↑ | Hyper + ↑ | ✅ GLEICH |
| Fenster Unten fokussieren | Hyper + ↓ | Hyper + ↓ | ✅ GLEICH |
| Fenster Links tauschen | Hyper+ + ← | Hyper+ + ← | ✅ GLEICH |
| Fenster Rechts tauschen | Hyper+ + → | Hyper+ + → | ✅ GLEICH |
| Fenster Oben tauschen | Hyper+ + ↑ | Hyper+ + ↑ | ✅ GLEICH |
| Fenster Unten tauschen | Hyper+ + ↓ | Hyper+ + ↓ | ✅ GLEICH |

### Toggle-Modi

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Fullscreen | Hyper + Return | Hyper + Return | ✅ GLEICH |
| Float Toggle | Hyper+ + Return | Hyper+ + Return | ✅ GLEICH |
| Layout Toggle | Hyper + K | Hyper + K | ⚠️ GEÄNDERT |
| Smart Balance | Hyper+ + K | Hyper+ + K | 🔄 ANGEPASST |
| Rotation 270° | Hyper + . | Hyper + . | ✅ GLEICH |
| Rotation 90° | Hyper + , | Hyper + , | ✅ GLEICH |
| Window Shadows | Hyper+ + S | ❌ N/A | ❌ ENTFÄLLT |

**⚠️ Layout Toggle Änderung:**
- **Yabai:** BSP ↔ Stack (+ Unfloat-Recovery)
- **Aerospace:** tiles ↔ accordion ↔ floating

**🔄 Smart Balance:**
- **Yabai:** Grid-Layouts je nach Fensteranzahl
- **Aerospace:** Automatisches Balance bei tiles-Layout

---

## WORKSPACE-MANAGEMENT

### Navigation

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Workspace Previous | Hyper + J | Hyper + J | ✅ GLEICH |
| Workspace Next | Hyper + L | Hyper + L | ✅ GLEICH |
| Workspace 1 | Hyper + 1 | Hyper + 1 | ✅ GLEICH |
| Workspace 2 | Hyper + 2 | Hyper + 2 | ✅ GLEICH |
| Workspace 3-9 | Hyper + [3-9] | Hyper + [3-9] | ✅ GLEICH |
| Workspace 10 | Hyper + 0 | ❌ N/A | ⚠️ ENTFÄLLT |
| **Workspace Code** | ❌ N/A | **Hyper + C** | ✅ NEU |
| **Workspace Music** | ❌ N/A | **Hyper + M** | ✅ NEU |
| **Workspace Browser** | ❌ N/A | **Hyper + B** | ✅ NEU |
| **Workspace Email** | ❌ N/A | **Hyper + E** | ✅ NEU |
| **Workspace Terminal** | ❌ N/A | **Hyper + T** | ✅ NEU |

**⚠️ Workspace 10 entfällt:** Ersetzt durch Buchstaben-Workspaces

### Fenster verschieben

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Zu vorherigem Workspace | Hyper+ + J | Hyper+ + J | ✅ GLEICH |
| Zu nächstem Workspace | Hyper+ + L | Hyper+ + L | ✅ GLEICH |
| Zu Workspace 1 | Hyper+ + 1 | Hyper+ + 1 | ✅ GLEICH |
| Zu Workspace 2 | Hyper+ + 2 | Hyper+ + 2 | ✅ GLEICH |
| Zu Workspace 3-9 | Hyper+ + [3-9] | Hyper+ + [3-9] | ✅ GLEICH |
| Zu Workspace 10 | Hyper+ + 0 | ❌ N/A | ⚠️ ENTFÄLLT |
| **Zu Workspace Code** | ❌ N/A | **Hyper+ + C** | ✅ NEU |
| **Zu Workspace Music** | ❌ N/A | **Hyper+ + M** | ✅ NEU |
| **Zu Workspace Browser** | ❌ N/A | **Hyper+ + B** | ✅ NEU |
| **Zu Workspace Email** | ❌ N/A | **Hyper+ + E** | ✅ NEU |
| **Zu Workspace Terminal** | ❌ N/A | **Hyper+ + T** | ✅ NEU |

### Workspace-Operationen

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Neuer Workspace | Hyper + N | ✅ Automatisch | 🔄 AUTO |
| Workspace löschen | Hyper + Z | ✅ Automatisch | 🔄 AUTO |
| Leere Workspaces löschen | Hyper+ + Z | ✅ Automatisch | 🔄 AUTO |
| Space Explosion | Hyper + D | ❌ N/A | ❌ ENTFÄLLT |
| Space Implosion | Hyper+ + D | ❌ N/A | ❌ ENTFÄLLT |
| Mission Control | Hyper + Space | ⚠️ Angepasst | ⚠️ GEÄNDERT |

**🔄 Workspace-Lifecycle:**
- **Yabai:** Manuelles Erstellen/Löschen nötig
- **Aerospace:** Automatisches Erstellen bei move-to-non-existing, Auto-Cleanup bei leer

**❌ Space Explosion/Implosion:**
- Unterschiedliche Layout-Logik in Aerospace
- Alternative: Layouts per Shortcut wechseln (tiles/accordion)

**⚠️ Mission Control:**
- Yabai nutzte nativen Mission Control
- Aerospace hat eigenes Workspace-Overview (falls implementiert)

---

## MULTI-MONITOR MANAGEMENT

**Konzept-Unterschied:**
- **Yabai:** Jeder Monitor hat eigene Spaces (Mission Control) - z.B. Monitor 1: Space 1-10, Monitor 2: Space 11-20
- **Aerospace:** Virtuelle Workspaces können zwischen Monitoren wandern (Option 2: Dynamisch)

### Monitor-Operationen

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Window → Nächster Monitor | Hyper + I | Hyper + I | ✅ GLEICH |
| Focus → Previous Monitor | ❌ N/A | **Hyper + U** | ✅ NEU |
| Focus → Next Monitor | ❌ N/A | **Hyper + P** | ✅ NEU |
| Workspace → Previous Monitor | ❌ N/A | **Hyper+ + U** | ✅ NEU |
| Workspace → Next Monitor | ❌ N/A | **Hyper+ + P** | ✅ NEU |

**✅ NEU in Aerospace:**
- **Hyper + U/P:** Monitor-Fokus wechseln (ohne Fenster zu bewegen)
- **Hyper+ + U/P:** Workspace zwischen Monitoren verschieben (KEY für dynamisches Multi-Monitor!)

**⚠️ WICHTIG:**
- Hyper+J/L wechselt Workspaces auf AKTUELLEM Monitor
- Workspace "erscheint" wo du gerade fokussiert bist
- Mit Hyper+ +U/P kannst du Workspace auf anderen Monitor verschieben

**Beispiel-Workflow:**
1. `Hyper + E` → Workspace E erscheint auf aktuellem Monitor
2. `Hyper+ + P` → Workspace E wandert zu anderem Monitor
3. `Hyper + U` → Fokus zum anderen Monitor wechseln
4. `Hyper + J/L` → Workspace wechseln auf aktuellem Monitor

---

### Workspace-Modi

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Fenster → Neuer Workspace + Max | Hyper + M | ⚠️ Angepasst | ⚠️ GEÄNDERT |
| Andere Fenster minimize/restore | Hyper+ + P | 🔄 Angepasst | 🔄 ANGEPASST |
| Fenster klein in Ecke | Hyper+ + M | Hyper+ + M | ✅ GLEICH |

**⚠️ Hyper + M Änderung:**
- Aerospace erstellt Workspace automatisch bei move-to-non-existing
- Maximieren via `fullscreen` command

---

## SYSTEM & SERVICES

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| YabaiIndicator restart | Hyper + \ | ❌ N/A | ❌ ENTFÄLLT |
| Fix Space Associations | Hyper+ + F | ❌ N/A | ❌ ENTFÄLLT |
| Aerospace reload config | ❌ N/A | Hyper + \ | ✅ NEU |

**✅ NEU: Hyper + \**
- Lädt Aerospace-Config neu
- Command: `aerospace reload-config`

**❌ Fix Space Associations:**
- Nicht nötig (virtuelle Workspaces ohne Display-Abhängigkeit)

---

## MUSCLE MEMORY GUIDE

### Was bleibt GLEICH ✅
- **Alle Focus/Swap-Shortcuts** (Hyper + Pfeile)
- **Workspace 1-9 Navigation** (Hyper + [1-9])
- **Fenster zu Workspace** (Hyper+ + [1-9])
- **Display Movement** (Hyper + I/O)
- **Fullscreen/Float** (Hyper + Return, Hyper+ + Return)

### Was ist NEU ✅
- **Buchstaben-Workspaces** (C, M, B, E, T)
- **Hybrid-Navigation:** Zahlen + Buchstaben gemischt
- **Auto-Workspace-Lifecycle:** Kein manuelles Erstellen/Löschen

### Was ENTFÄLLT ❌
- **Workspace 10** (Hyper + 0)
- **Space Explosion/Implosion** (Hyper + D/D+)
- **Window Shadows** (Hyper+ + S)
- **Fix Space Associations** (Hyper+ + F)
- **YabaiIndicator restart** (Hyper + \)

### Was sich ÄNDERT ⚠️
- **Layout Toggle** (Hyper + K): BSP/Stack → tiles/accordion/floating
- **Mission Control** (Hyper + Space): Aerospace-eigenes System
- **Workspace-Lifecycle:** Automatisch statt manuell

---

## AEROSPACE-CONFIG REFERENZ

### Workspace-Navigation

```toml
[mode.main.binding]
# Direct Workspace Switch
ctrl-alt-shift-1 = 'workspace 1'
ctrl-alt-shift-2 = 'workspace 2'
ctrl-alt-shift-3 = 'workspace 3'
ctrl-alt-shift-4 = 'workspace 4'
ctrl-alt-shift-5 = 'workspace 5'
ctrl-alt-shift-6 = 'workspace 6'
ctrl-alt-shift-7 = 'workspace 7'
ctrl-alt-shift-8 = 'workspace 8'
ctrl-alt-shift-9 = 'workspace 9'
ctrl-alt-shift-c = 'workspace C'
ctrl-alt-shift-m = 'workspace M'
ctrl-alt-shift-b = 'workspace B'
ctrl-alt-shift-e = 'workspace E'
ctrl-alt-shift-t = 'workspace T'

# Circular Navigation
ctrl-alt-shift-j = 'workspace --wrap-around prev'
ctrl-alt-shift-l = 'workspace --wrap-around next'
```

### Window Movement

```toml
# Focus
ctrl-alt-shift-left = 'focus left'
ctrl-alt-shift-right = 'focus right'
ctrl-alt-shift-up = 'focus up'
ctrl-alt-shift-down = 'focus down'

# Swap
ctrl-alt-shift-cmd-left = 'move left'
ctrl-alt-shift-cmd-right = 'move right'
ctrl-alt-shift-cmd-up = 'move up'
ctrl-alt-shift-cmd-down = 'move down'

# Move to Workspace
ctrl-alt-shift-cmd-1 = 'move-node-to-workspace 1'
ctrl-alt-shift-cmd-2 = 'move-node-to-workspace 2'
# ... etc
ctrl-alt-shift-cmd-c = 'move-node-to-workspace C'
ctrl-alt-shift-cmd-m = 'move-node-to-workspace M'
# ... etc

# Circular Move
ctrl-alt-shift-cmd-j = 'move-node-to-workspace --wrap-around prev'
ctrl-alt-shift-cmd-l = 'move-node-to-workspace --wrap-around next'
```

### Layouts

```toml
# Layout Toggle
ctrl-alt-shift-k = 'layout tiles horizontal vertical'

# Fullscreen
ctrl-alt-shift-return = 'fullscreen'

# Float
ctrl-alt-shift-cmd-return = 'layout floating tiling'

# Rotation
ctrl-alt-shift-0x2F = 'layout tiles horizontal vertical'  # Period (.)
ctrl-alt-shift-0x2B = 'layout tiles vertical horizontal'  # Comma (,)
```

### Display Management

```toml
# Move to next Monitor
ctrl-alt-shift-i = 'move-node-to-monitor --wrap-around next'
```

### System

```toml
# Reload Config
ctrl-alt-shift-0x2A = 'reload-config'  # Backslash (\)
```

---

## TIPPS FÜR DEN ÜBERGANG

### Woche 1: Basis-Navigation
- **Fokus:** Workspace 1-9 + Focus/Swap
- **Muscle Memory:** Identisch zu Yabai
- **Neue Shortcuts ignorieren:** Noch nicht C/M/B/E/T nutzen

### Woche 2: Buchstaben-Workspaces
- **Fokus:** C/M/B/E/T erkunden
- **Use Case festlegen:**
  - C = VS Code, Terminal, IDEs
  - M = Spotify, iTunes
  - B = Browser-Windows
  - E = Mail.app
  - T = Dedizierte Shell-Sessions
- **Muscle Memory aufbauen:** Bewusst Buchstaben-Shortcuts nutzen

### Woche 3: Layout-System
- **Fokus:** tiles/accordion/floating verstehen
- **Unterschied zu Yabai:**
  - tiles = BSP-ähnlich
  - accordion = Stack-ähnlich (alle Fenster übereinander)
  - floating = wie Yabai float
- **Experimentieren:** Hyper + K mehrfach drücken

### Woche 4: Workflows optimieren
- **Fokus:** App-Zuordnungen verfeinern
- **Auto-Assignment nutzen:** Apps automatisch zu Workspaces
- **Scripts anpassen:** Eigene Workflows portieren

---

## HÄUFIGE FEHLER

### ❌ Workspace 10 nicht verfügbar
**Problem:** Hyper + 0 funktioniert nicht mehr
**Lösung:** Workspace 10 durch Buchstaben-Workspace ersetzen

### ❌ Space Explosion fehlt
**Problem:** Hyper + D macht nichts
**Lösung:** Aerospace hat andere Layout-Logik, Layouts per Shortcut wechseln

### ❌ Mission Control zeigt keine Workspaces
**Problem:** Aerospace-Workspaces sind virtuell
**Lösung:** Gewöhnung, Cmd+Tab funktioniert weiter für Apps

### ❌ Layout Toggle verhält sich anders
**Problem:** Hyper + K macht nicht BSP ↔ Stack
**Lösung:** Mehrfach drücken für tiles → accordion → floating

### ❌ Fenster "verschwinden"
**Problem:** Minimierte Fenster nicht im Dock
**Lösung:** Aerospace versteckt Fenster, nutze Workspace-Navigation

---

## CHEAT SHEET (DRUCK-VERSION)

### FOCUS & SWAP
```
Hyper + ← ↑ → ↓     Focus (NESW)
Hyper+ + ← ↑ → ↓    Swap (NESW)
```

### WORKSPACES
```
Hyper + [1-9]       Workspace 1-9
Hyper + C/M/B/E/T   Code/Music/Browser/Email/Terminal
Hyper + J/L         Prev/Next Workspace
```

### MOVE WINDOWS
```
Hyper+ + [1-9]      Zu Workspace 1-9
Hyper+ + C/M/B/E/T  Zu Code/Music/Browser/Email/Terminal
Hyper+ + J/L        Zu Prev/Next Workspace
```

### LAYOUTS
```
Hyper + Return      Fullscreen
Hyper+ + Return     Float
Hyper + K           Layout Toggle (tiles/accordion/float)
Hyper + . / ,       Rotation 270° / 90°
```

### DISPLAY
```
Hyper + I           Fenster zu nächstem Display
Hyper + O           Alle Fenster zu nächstem Display
```

### SYSTEM
```
Hyper + \           Aerospace Config neu laden
```

---

**Status-Legende:**
- ✅ GLEICH - Identisch zu Yabai
- ✅ NEU - Neue Funktion in Aerospace
- 🔄 ANGEPASST - Funktion angepasst
- ⚠️ GEÄNDERT - Verhalten geändert
- ❌ ENTFÄLLT - Nicht verfügbar in Aerospace

---

*Dieses Cheat Sheet wird aktualisiert wenn neue Shortcuts hinzukommen!*
