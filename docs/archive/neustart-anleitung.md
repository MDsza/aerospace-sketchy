# Neustart-Anleitung: Sauberer Aerospace-Start

**Datum:** 2025-11-11 13:25
**Phase:** 2 → Abschluss
**Zweck:** Aerospace ohne Window-Manager-Konflikte starten

---

## VORBEREITUNGEN (BEREITS ERLEDIGT ✅)

- [x] Yabai Service gestoppt (`yabai --stop-service`)
- [x] SKHD Service gestoppt (`skhd --stop-service`)
- [x] Aerospace Config korrekt (`~/.aerospace.toml`)
- [x] Aerospace start-at-login = true
- [x] Keine Yabai/SKHD Prozesse mehr laufend

---

## NACH NEUSTART: WAS PASSIERT

### Automatisch beim Boot

**1. macOS startet**
- Mission Control mit "Displays have separate Spaces" initialisiert

**2. Login**
- LaunchAgent startet (falls vorhanden)

**3. Aerospace startet automatisch**
- `start-at-login = true` in Config
- Übernimmt alle Fenster von Anfang an
- KEINE Konflikte (kein anderer Window Manager läuft)

**4. Sketchybar läuft weiter**
- Noch mit Yabai-Config (Phase 4 anpassen)
- Zeigt möglicherweise falsche Workspace-Infos (OK, wird später gefixt)

---

## NACH NEUSTART: TESTS DURCHFÜHREN

### Test 1: Aerospace Status

```bash
aerospace --version
```

**Erwartung:**
```
aerospace CLI client version: 0.19.2-Beta
AeroSpace.app server version: 0.19.2-Beta
```

✅ = Server läuft
❌ = Accessibility Permission fehlt (System Settings aktivieren)

---

### Test 2: Workspaces

```bash
aerospace list-workspaces --focused
```

**Erwartung:**
```
1  # oder ein anderer Workspace
```

✅ = Workspaces funktionieren

---

### Test 3: Shortcuts (WICHTIGSTER TEST!)

**Tastatur-Tests:**
```
Alt + 1       → Workspace 1
Alt + 2       → Workspace 2
Alt + 3       → Workspace 3

Alt + h       → Fokus links
Alt + l       → Fokus rechts
Alt + j       → Fokus unten
Alt + k       → Fokus oben

Alt + Shift + 1  → Fenster zu Workspace 1
Alt + Shift + 2  → Fenster zu Workspace 2
```

**Prüfe:**
- ✅ Workspace-Wechsel SMOOTH (kein Flimmern!)
- ✅ Fenster bleiben stabil
- ✅ Keine Bildfehler
- ✅ Focus-Wechsel funktioniert

---

### Test 4: Window Management

**Öffne mehrere Fenster:**
1. Terminal öffnen
2. Safari öffnen
3. Beide zu Workspace 2 verschieben (Alt + Shift + 2)

**Teste:**
```
Alt + 2       → Zu Workspace 2
Alt + h/l     → Zwischen Terminal und Safari wechseln
```

**Prüfe:**
- ✅ Tiling funktioniert (Fenster nebeneinander)
- ✅ Focus-Highlighting sichtbar
- ✅ Smooth, keine Glitches

---

## FALLS PROBLEME AUFTRETEN

### Problem 1: Aerospace startet nicht

**Symptom:** Server version: Unknown

**Lösung:**
1. System Settings → Privacy & Security → Accessibility
2. Aerospace aktivieren (Checkbox ✓)
3. Aerospace neu starten: `killall AeroSpace && open -a AeroSpace && aerospace reload-config`

---

### Problem 2: Flimmern beim Workspace-Wechsel

**Symptom:** Bildschirm flackert/flimmert bei Alt + 1/2/3

**Check 1: Yabai läuft noch?**
```bash
ps aux | grep yabai | grep -v grep
```

Falls Output → Yabai läuft noch!
```bash
yabai --stop-service
killall yabai
```

**Check 2: macOS Animations?**
```
System Settings → Accessibility → Display
→ "Reduce motion" aktivieren (Test)
```

---

### Problem 3: Shortcuts funktionieren nicht

**Check: PRAM Clear nötig?**

1. Mac herunterfahren
2. Einschalten + sofort **Cmd + Opt + P + R** halten
3. Warten bis 2× Bootsound / Apfel-Logo 2×
4. Tasten loslassen

Danach: Aerospace Config neu laden
```bash
aerospace reload-config
```

---

### Problem 4: Bildfehler/Glitches

**Erste Maßnahme:**
```bash
# Aerospace komplett neu starten
killall AeroSpace
sleep 2
open -a AeroSpace
aerospace reload-config   # WICHTIG: sonst lädt Aerospace die Default-Workspaces!
```

**Falls weiterhin Probleme:**
→ Rollback zu Yabai
```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy
./scripts/rollback-to-yabai.sh
```

---

## ERFOLG: PHASE 2 ABGESCHLOSSEN ✅

**Checkliste:**
- [x] Aerospace läuft smooth
- [x] Workspace-Wechsel ohne Flimmern
- [x] Test-Shortcuts funktionieren
- [x] Fenster-Management funktioniert
- [x] Keine Bildfehler

**Nächster Schritt:** Phase 3 - Config Migration
- Hyper-Shortcuts konfigurieren (Karabiner CapsLock)
- Workspace-Mapping (Q W E R T / A S D F G + Overflow X/Y/Z)
- Window Rules portieren
- App-Zuordnungen

---

## ROLLBACK (FALLS NÖTIG)

**Falls Aerospace nicht zufriedenstellend:**

```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy
./scripts/rollback-to-yabai.sh
```

**Effekt:**
- Aerospace deaktiviert
- Yabai + SKHD wieder aktiviert
- System wie vor Migration

---

**Stand gesichert, bereit für Neustart!**
