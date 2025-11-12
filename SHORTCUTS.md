# SHORTCUTS TRANSITION GUIDE

Yabai+SKHD → Aerospace Migration
**Production Version 1.0** (Phase 3 Complete)

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

**✅ Mouse-Follows-Focus:**
- Alle Focus-Commands zentrieren Maus automatisch auf neuem Fenster
- Script: `focus-and-center.sh`

### Toggle-Modi

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Fullscreen | Hyper + Return | Hyper + Return | ✅ GLEICH |
| Float Toggle | Hyper+ + Return | Hyper+ + Return | ✅ GLEICH |
| Layout Toggle | Hyper + K | **Hyper + K** | ⚠️ GEÄNDERT |
| Balance | Hyper+ + O | **Hyper+ + B** | ⚠️ GEÄNDERT |
| Rotation Horizontal | Hyper + . | Hyper + . | ✅ GLEICH |
| Rotation Vertical | Hyper + , | Hyper + , | ✅ GLEICH |

**⚠️ Hyper+K - Layout Toggle:**
- **Yabai:** BSP ↔ Stack
- **Aerospace:** tiles ↔ accordion
  - **tiles:** Fenster nebeneinander (BSP-ähnlich)
  - **accordion:** Fenster übereinander (Stack-ähnlich)

**⚠️ Hyper++B - Balance verschoben:**
- War Hyper++O, jetzt Hyper++B
- Grund: Hyper+O nun für Workspace-to-Monitor

---

## WORKSPACE-MANAGEMENT (QWERTZ-LAYOUT)

### Navigation - QWERTZ Fixed Layout

**10 feste Workspaces basierend auf Tastatur (linke Hand):**

```
Row 1:  Q    W    E    R    T
Row 2:  A    S    D    F    G
```

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Workspace Q (Queries) | ❌ N/A | **Hyper + Q** | ✅ NEU |
| Workspace W (Work) | ❌ N/A | **Hyper + W** | ✅ NEU |
| Workspace E (Email) | ❌ N/A | **Hyper + E** | ✅ NEU |
| Workspace R | ❌ N/A | **Hyper + R** | ✅ NEU |
| Workspace T | ❌ N/A | **Hyper + T** | ✅ NEU |
| Workspace A (AI) | ❌ N/A | **Hyper + A** | ✅ NEU |
| Workspace S (Search) | ❌ N/A | **Hyper + S** | ✅ NEU |
| Workspace D (Do) | ❌ N/A | **Hyper + D** | ✅ NEU |
| Workspace F (Files) | ❌ N/A | **Hyper + F** | ✅ NEU |
| Workspace G | ❌ N/A | **Hyper + G** | ✅ NEU |
| Workspace Previous | Hyper + J | Hyper + J | ✅ GLEICH |
| Workspace Next | Hyper + L | Hyper + L | ✅ GLEICH |

**🔄 Overflow Workspaces (Multi-Monitor):**

| Workspace | Verwendung |
|-----------|------------|
| **X** | Overflow Monitor 1 (Fenster ohne feste Zuordnung) |
| **Y** | Overflow Monitor 2 |
| **Z** | Overflow Monitor 3+ |

**Automatisch erstellt bei Smart Window Move (Hyper+I)**

### Fenster verschieben (QWERTZ-Layout)

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Zu Workspace Q | ❌ N/A | **Hyper+ + Q** | ✅ NEU |
| Zu Workspace W | ❌ N/A | **Hyper+ + W** | ✅ NEU |
| Zu Workspace E | ❌ N/A | **Hyper+ + E** | ✅ NEU |
| Zu Workspace R | ❌ N/A | **Hyper+ + R** | ✅ NEU |
| Zu Workspace T | ❌ N/A | **Hyper+ + T** | ✅ NEU |
| Zu Workspace A | ❌ N/A | **Hyper+ + A** | ✅ NEU |
| Zu Workspace S | ❌ N/A | **Hyper+ + S** | ✅ NEU |
| Zu Workspace D | ❌ N/A | **Hyper+ + D** | ✅ NEU |
| Zu Workspace F | ❌ N/A | **Hyper+ + F** | ✅ NEU |
| Zu Workspace G | ❌ N/A | **Hyper+ + G** | ✅ NEU |
| Zu Prev Workspace | Hyper+ + J | Hyper+ + J | ✅ GLEICH |
| Zu Next Workspace | Hyper+ + L | Hyper+ + L | ✅ GLEICH |

**✅ Focus-Follow:**
- Alle move-and-follow Scripts folgen Fenster automatisch
- Wie Yabai-Verhalten

### Workspace-Zuordnungen (App-Based Auto-Assignment)

| Workspace | Mnemonic | Apps |
|-----------|----------|------|
| **Q** | **Q**ueries | Obsidian |
| **W** | **W**ork | Citrix, WATTs Up |
| **E** | **E**mail | Outlook, Mail |
| **R** | Reserved | - |
| **T** | - | - |
| **A** | **A**I | VS Code, Claude, ChatGPT, Cursor, Jupyter |
| **S** | **S**earch | Safari, Chrome, Firefox, Brave, Arc |
| **D** | **D**o | Things, OmniFocus, Todoist |
| **F** | **F**iles | Finder, Forklift, PathFinder |
| **G** | - | - |

**Auto-Assignment via .aerospace.toml:**
- Fenster werden automatisch zugeordnet bei window-detected
- Workspace-Icons in Sketchybar zeigen zugeordnete Apps

---

## MULTI-MONITOR MANAGEMENT

### Monitor-Operationen

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| **Window → Monitor (Smart)** | Hyper + I | **Hyper + I** | ✅ VERBESSERT |
| **Workspace → Monitor** | Hyper + O | **Hyper + O** | ⚠️ GEÄNDERT |
| Focus → Previous Monitor | ❌ N/A | **Hyper + U** | ✅ NEU |
| Focus → Next Monitor | ❌ N/A | **Hyper + P** | ✅ NEU |
| Workspace → Prev Monitor | ❌ N/A | **Hyper+ + U** | ✅ NEU |
| Workspace → Next Monitor | ❌ N/A | **Hyper+ + P** | ✅ NEU |

**✅ VERBESSERT: Hyper+I - Smart Window-to-Monitor Move**

Intelligente Workspace-Erstellung verhindert numerische Workspaces:

1. **Ziel-Monitor hat Workspaces:** Normales Move
2. **Ziel-Monitor leer:**
   - **App hat Zuordnung:** Erstellt zugeordneten Workspace (z.B. VS Code → A)
   - **App ohne Zuordnung:** Erstellt Overflow-Workspace X/Y/Z

**Script:** `move-window-to-monitor.sh`

**⚠️ GEÄNDERT: Hyper+O - Workspace-to-Monitor**
- **Vorher:** Hyper++U (Primärfunktion nun Hyper+O)
- **Jetzt:** Verschiebt gesamten Workspace auf anderen Monitor
- **Hauptfunktion für dynamisches Multi-Monitor-Setup!**

---

## SYSTEM & SERVICES

| Funktion | Yabai+SKHD | Aerospace | Status |
|----------|------------|-----------|--------|
| Config neu laden | Hyper + \ | Hyper + \ | ✅ GLEICH |
| Doppelklick Apple-Logo | ❌ N/A | **Kompletter Reload** | ✅ NEU |
| Workspace erstellen | Hyper + N | ❌ Deaktiviert | ❌ ENTFÄLLT |
| Workspace löschen | Hyper + Z | ❌ Deaktiviert | ❌ ENTFÄLLT |

**✅ NEU: Apple-Logo Doppelklick**
- Kompletter Reload: Aerospace + Sketchybar
- Force-Kill + Lock-File-Remove
- Korrigiert Front-App-Position

**❌ Hyper+N/Z deaktiviert:**
- Nicht mehr nötig mit Fixed QWERTZ-Layout (Q-G) + Overflow (X-Z)
- Workspaces sind immutable names

---

## GAPS & BORDERS (JankyBorders Integration)

**Neu konfiguriert:**

```toml
[gaps]
inner.horizontal = 5
inner.vertical = 5
outer.left = 5
outer.right = 5
outer.top = 5
outer.bottom = 35  # Sketchybar (30) + Border (5)
```

**Resultat:**
- 5px Abstand zwischen Fenstern
- 5px Abstand zu Bildschirmrändern
- JankyBorders-Rahmen vollständig sichtbar (nicht abgeschnitten)

---

## MUSCLE MEMORY GUIDE

### Was bleibt GLEICH ✅
- **Alle Focus/Swap-Shortcuts** (Hyper + Pfeile)
- **Workspace Prev/Next** (Hyper + J/L)
- **Fenster zu Workspace** (Hyper+ + J/L)
- **Fullscreen/Float** (Hyper + Return, Hyper+ + Return)
- **Rotation** (Hyper + , / .)

### Was ist NEU ✅
- **QWERTZ-Workspaces** (Q W E R T / A S D F G)
- **Overflow-Workspaces** (X Y Z für Multi-Monitor)
- **Smart Window-to-Monitor** (Hyper+I mit App-Assignment)
- **Workspace-to-Monitor** (Hyper+O - Hauptfunktion!)
- **Layout Toggle tiles↔accordion** (Hyper+K)
- **Monitor-Fokus** (Hyper+U/P)
- **Apple-Logo Doppelklick** (Kompletter Reload)

### Was ENTFÄLLT ❌
- **Numerische Workspaces 1-10** (Ersetzt durch QWERTZ)
- **Hyper+N** (Workspace erstellen - nicht mehr nötig)
- **Hyper+Z** (Workspace löschen - nicht mehr nötig)
- **Space Explosion/Implosion** (Andere Layout-Logik)
- **Window Shadows** (Nicht in Aerospace)

### Was sich ÄNDERT ⚠️
- **Balance:** Hyper++O → **Hyper++B**
- **Workspace-to-Monitor:** Hyper++U → **Hyper+O**
- **Layout Toggle:** BSP/Stack → **tiles/accordion**

---

## CHEAT SHEET (DRUCK-VERSION)

### FOCUS & SWAP
```
Hyper + ← ↑ → ↓     Focus + Mouse Center
Hyper+ + ← ↑ → ↓    Swap Windows
```

### WORKSPACES (QWERTZ-LAYOUT)
```
Hyper + Q W E R T   Row 1 Workspaces
Hyper + A S D F G   Row 2 Workspaces
Hyper + J / L       Prev / Next Workspace
```

### MOVE WINDOWS (QWERTZ-LAYOUT)
```
Hyper+ + Q W E R T  Zu Row 1 Workspaces
Hyper+ + A S D F G  Zu Row 2 Workspaces
Hyper+ + J / L      Zu Prev/Next + Follow
```

### LAYOUTS
```
Hyper + Return      Fullscreen
Hyper+ + Return     Float Toggle
Hyper + K           Layout Toggle (tiles ↔ accordion)
Hyper + . / ,       Rotation Horizontal / Vertical
Hyper+ + B          Balance Sizes
```

### MULTI-MONITOR (★ KEY FEATURES)
```
Hyper + I           Smart Window → Monitor (mit X/Y/Z)
Hyper + O           Workspace → Monitor (HAUPTFUNKTION!)
Hyper + U / P       Focus Monitor Prev / Next
Hyper+ + U / P      Workspace → Monitor Prev / Next
```

### SYSTEM
```
Hyper + \           Aerospace Config Reload
Double-Click 🍎     Kompletter Reload (Aerospace + Sketchybar)
```

---

## WORKSPACE-SEMANTIK

### Fixed Workspaces (QWERTZ)
```
Q - Queries:  Obsidian
W - Work:     Citrix, WATTs Up
E - Email:    Outlook, Mail
R - Reserved
T - (offen)

A - AI:       VS Code, Claude, ChatGPT, Cursor, Jupyter
S - Search:   Safari, Chrome, Firefox, Brave, Arc
D - Do:       Things, OmniFocus, Todoist
F - Files:    Finder, Forklift, PathFinder
G - (offen)
```

### Overflow Workspaces (Multi-Monitor)
```
X - Monitor 1 Overflow (Apps ohne feste Zuordnung)
Y - Monitor 2 Overflow
Z - Monitor 3+ Overflow
```

**Automatisch erstellt bei Hyper+I auf leeren Monitor**

---

## TIPPS FÜR DEN ÜBERGANG

### Tag 1: QWERTZ-Layout lernen
- **Linke Hand Position:** Q W E R T über A S D F G
- **Muscle Memory:** Tastatur-basiert statt Zahlen
- **Start einfach:** Nur Q/E/A/S/D nutzen (häufigste Apps)

### Woche 1: Basis-Workflows
- Workspace-Navigation mit Hyper+Q/E/A/S/D/F
- Apps automatisch zuordnen lassen (Auto-Assignment)
- Hyper+J/L für sequentielle Navigation

### Woche 2: Multi-Monitor optimieren
- **Hyper+O** meistern (Workspace-to-Monitor)
- **Hyper+I** mit Smart-Assignment testen
- Overflow-Workspaces X/Y/Z verstehen

### Woche 3: Layout-System
- **Hyper+K** für tiles ↔ accordion
- Unterschied zu Yabai BSP/Stack verstehen
- Workflows anpassen (tiles für Code, accordion für Fullscreen-Apps)

---

## HÄUFIGE FEHLER & LÖSUNGEN

### ❌ "Workspaces 1-9 fehlen!"
**Lösung:** QWERTZ-Layout (Q-G) ersetzt numerische Workspaces. Muscle Memory umlernen.

### ❌ "Hyper+N macht nichts!"
**Lösung:** Deaktiviert. Fixed QWERTZ-Layout benötigt keine dynamischen Workspaces.

### ❌ "Programmname (Code) links von Workspaces!"
**Lösung:** Doppelklick auf Apple-Logo (🍎) → Kompletter Reload korrigiert Position.

### ❌ "Rahmen (JankyBorders) wird abgeschnitten!"
**Lösung:** Bereits konfiguriert. Gaps: inner 5px, outer 5px. Aerospace neu starten falls nötig.

### ❌ "Workspace-to-Monitor funktioniert nicht!"
**Lösung:** **Hyper+O** (nicht mehr Hyper++U). Hauptfunktion für dynamisches Multi-Monitor.

---

**Status-Legende:**
- ✅ GLEICH - Identisch zu Yabai
- ✅ NEU - Neue Funktion in Aerospace
- ✅ VERBESSERT - Funktion erweitert
- 🔄 ANGEPASST - Funktion angepasst
- ⚠️ GEÄNDERT - Verhalten/Keybinding geändert
- ❌ ENTFÄLLT - Nicht verfügbar in Aerospace

---

**Version:** 1.0 (Phase 3 Complete)
**Letzte Aktualisierung:** 2025-11-12
**Migration:** Yabai+SKHD → Aerospace Complete
