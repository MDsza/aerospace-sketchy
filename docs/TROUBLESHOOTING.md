# TROUBLESHOOTING.md
# Aerospace + Sketchybar - Häufige Probleme und Lösungen

## 🔴 CRITICAL: Sketchybar Lock-File-Problem

### Problem-Symptome
- Sketchybar startet nicht: `could not acquire lock-file... already running?`
- Sketchybar startet nicht: `could not initialize daemon! abort..`
- Workspaces werden nicht angezeigt/nicht klickbar/nicht highlighted
- Mehrere Lua-Prozesse laufen gleichzeitig

### Root Cause
**Mehrfache Sketchybar-Neustart-Versuche erzeugen Zombie-Prozesse**, die das Lock-File halten:
- 1x sketchybar Daemon
- **3-5x lua Prozesse** (von fehlgeschlagenen Restarts)
- Lock-File: `/tmp/sketchybar_$USER.lock`

### Diagnose
```bash
# Prüfe laufende Prozesse
ps aux | grep -E '[s]ketchybar|[l]ua.*sketchybar'

# Prüfe Lock-File
lsof /tmp/sketchybar_wolfgang.lock

# Erwartetes Ergebnis (SAUBER):
# - 1x /opt/homebrew/opt/sketchybar/bin/sketchybar
# - 1x lua /Users/wolfgang/.config/sketchybar/sketchybarrc

# Problematisch (MEHRERE Lua-Prozesse):
# - 1x sketchybar
# - 3-5x lua /Users/wolfgang/.config/sketchybar/sketchybarrc  ← PROBLEM!
```

### Lösung 1: Brew Services Restart (EMPFOHLEN)
```bash
# Methode A: Brew Services (sauberste Methode)
killall -9 sketchybar lua 2>/dev/null
sleep 2
brew services restart sketchybar

# Warte 3 Sekunden, dann teste
sleep 3
sketchybar --query bar
```

### Lösung 2: Manuelles Force-Clean
```bash
# Methode B: Manuell (wenn brew services nicht hilft)
pkill -9 sketchybar
pkill -9 -f "lua.*sketchybar"
rm -f /tmp/sketchybar_$USER.lock
sleep 3
sketchybar

# Warte 3 Sekunden, dann teste
sleep 3
sketchybar --query bar
```

### Lösung 3: Apple-Logo Doppelklick (Soft-Refresh)
**Im laufenden System:**
1. Doppelklick auf Apple-Logo in Sketchybar (unten links)
2. Startet `scripts/refresh-aerospace-sketchy.sh` → Symlink-Check, `aerospace reload-config`, `sketchybar --reload`, Events triggern
3. Kein Force-Kill mehr nötig; der harte Neustart (`scripts/restart_services.sh`) bleibt als Fallback per Terminal

### Prävention
**WICHTIG: Nach jeder Sketchybar-Config-Änderung:**

1. **Nur EINE Methode verwenden:**
   - Apple-Logo Doppelklick (Soft-Refresh, EMPFOHLEN)
   - ODER `brew services restart sketchybar`
   - ODER `pkill -9 sketchybar && sketchybar`
   - **NIEMALS mehrfach hintereinander hart restarten!**

2. **Warte immer 3-5 Sekunden** zwischen Stop und Start:
   ```bash
   pkill -9 sketchybar
   sleep 3  # ← WICHTIG!
   sketchybar
   ```

3. **Vermeide `aerospace reload-config`** für Sketchybar-Updates:
   - `aerospace reload-config` triggert Events, aber lädt Sketchybar NICHT neu
   - Nutze stattdessen das Refresh-Script oder `sketchybar --reload`

4. **Prüfe Prozess-Count nach Restart:**
   ```bash
   ps aux | grep -E '[s]ketchybar' | wc -l
   # Erwartung: 2 (1x sketchybar, 1x lua)
   # Problem: 4+ (mehrere Lua-Prozesse)
   ```

---

## ⚠️ Workspace-Probleme

### Problem: Workspaces nicht klickbar / nicht highlighted
**Symptom:** Workspaces in Sketchybar zeigen keine Reaktion auf Klick oder Workspace-Wechsel

**Ursache:** Sketchybar wurde nicht sauber neu gestartet nach Config-Änderung

**Lösung:**
```bash
# Force-Clean Restart (siehe oben)
brew services restart sketchybar

# Teste Event-System
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=A

# Prüfe ob Workspace A highlighted ist
sketchybar --query space.A | grep "highlight"
# Erwartung: "highlight": "on"
```


## 🐌 Performance-Probleme

### Problem: Claude Code wird langsam / Timeout-Errors
**Symptom:** Antworten dauern sehr lange, Background-Tasks häufen sich

**Ursache:**
1. **Zu viele Background-Bash-Prozesse** (Zombie-Prozesse von alten Commands)
2. **Große Kontext-Größe** in Continued-Sessions (40k+ Tokens)

**Lösung:**
```bash
# 1. Kill Zombie-Prozesse
pkill -9 -f "aerospace list-"
pkill -9 -f "sketchybar --query"

# 2. Clean Background-Tasks (optional)
# Siehe /bashes für laufende Background-Tasks

# 3. Neue Claude-Session starten (wenn >40k Tokens)
# Context wird resettet, Performance verbessert
```

---

## 🔧 Aerospace-Probleme

### Problem: Zombie-Aerospace-Prozesse
**Symptom:** `ps aux | grep aerospace` zeigt alte Prozesse von vor Stunden

**Lösung:**
```bash
# Liste Zombie-Prozesse
ps aux | grep -E 'aerospace (list|enable|reload)' | grep -v grep

# Kill alte Prozesse (älter als 5 Minuten)
pkill -9 -f "aerospace list-"
pkill -9 -f "aerospace enable"
pkill -9 -f "aerospace reload"

# Haupt-Daemon sollte NICHT gekillt werden!
# /Applications/AeroSpace.app/Contents/MacOS/AeroSpace
```

---

## 📋 Diagnostics Checkliste

**Bei Problemen IMMER diese Schritte durchführen:**

```bash
# 1. Prüfe Sketchybar-Prozesse
ps aux | grep -E '[s]ketchybar' | wc -l
# Erwartung: 2 (1x daemon, 1x lua)

# 2. Prüfe Lock-File
ls -la /tmp/sketchybar_$USER.lock
lsof /tmp/sketchybar_$USER.lock

# 3. Prüfe Aerospace-Workspaces
aerospace list-workspaces --all
# Erwartung: Q W E R T A S D F G (+ evtl. X Y Z)

# 4. Prüfe Sketchybar-Items
sketchybar --query bar | grep "space\."
# Erwartung: space.Q, space.W, ..., space.G

# 5. Prüfe Event-System
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=A
sketchybar --query space.A | grep "highlight"
# Erwartung: "highlight": "on"

# 6. Prüfe Zombie-Prozesse
ps aux | grep -E 'aerospace (list|enable)' | grep -v grep
# Erwartung: Leer oder nur aktuelle Prozesse (<5 Sekunden alt)
```

---

## 🆘 Notfall-Reset (Last Resort)

**Wenn nichts hilft - Kompletter Reset:**

```bash
#!/bin/bash
# NOTFALL-RESET - NUR VERWENDEN WENN ALLES ANDERE FEHLSCHLÄGT!

echo "=== Stoppe alle Services ==="
brew services stop sketchybar
pkill -9 AeroSpace
sleep 3

echo "=== Clean alle Prozesse ==="
killall -9 sketchybar lua 2>/dev/null
pkill -9 -f "aerospace"
pkill -9 -f "sketchybar"
sleep 2

echo "=== Remove Lock-Files ==="
rm -f /tmp/sketchybar_$USER.lock
rm -f /tmp/aerospace*.lock 2>/dev/null
sleep 1

echo "=== Starte Services neu ==="
open -a AeroSpace
aerospace reload-config
sleep 2
brew services start sketchybar
sleep 3

echo "=== Diagnostics ==="
ps aux | grep -E '[A]eroSpace|[s]ketchybar' | head -5
sketchybar --query bar | head -20

echo "=== DONE ==="
```

---

## 📚 Siehe auch
- `README.md` - Setup-Anleitung
- `SHORTCUTS.md` - Keyboard-Shortcuts
- `PLAN.md` - Migrations-Status
- `~/.config/sketchybar/plugins/restart_services.sh` - Restart-Script
