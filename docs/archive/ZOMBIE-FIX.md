# Sketchybar Lua Zombie Fix

**Datum:** 2025-11-12
**Status:** GELÖST ✅

## Problem

### Symptome
- Apple-Logo Doppelklick wirft Error-Dialog: "Zombie-Prozesse gefunden"
- Mehrere Lua-Prozesse laufen parallel (3-5 statt 2)
- Workspaces nicht klickbar/highlighted nach Restart
- Lock-File `/tmp/sketchybar_$USER.lock` bleibt gesperrt

### Root Cause

**Brew services supervises nur den Sketchybar-Daemon, nicht die Lua-Worker!**

```
Prozess-Hierarchie:
/opt/homebrew/opt/sketchybar/bin/sketchybar  ← Brew überwacht DIESE PID
└── lua /Users/wolfgang/.config/sketchybar/sketchybarrc  ← Kind-Prozess (NICHT überwacht!)
```

**Was passiert bei schnellem Restart:**
1. `brew services restart sketchybar`
2. Daemon stirbt (PID gone)
3. **Lua-Worker bleibt in Event-Loop hängen**
4. Lock-File bleibt von totem Lua-Prozess gehalten
5. Neuer Sketchybar-Start spawnt neuen Lua-Worker
6. → **Mehrere Lua-Prozesse parallel = Zombies!**

## Lösung

### Hardened restart_services.sh

**Guards implementiert:**

#### 1. wait_for_exit() Helper
```bash
wait_for_exit() {
  local process_pattern="$1"
  local max_wait="${2:-5}"  # Default 5s
  local waited=0

  while [ $waited -lt $max_wait ]; do
    if ! pgrep -f "$process_pattern" > /dev/null 2>&1; then
      return 0  # Process gone
    fi
    sleep 1
    waited=$((waited + 1))
  done
  return 1  # Timeout
}
```

#### 2. Graceful Shutdown mit Wait
```bash
# SIGTERM first (erlaubt cleanup)
pkill -TERM sketchybar 2>/dev/null

# CRITICAL: Wait for Lua workers (max 5s)
if ! wait_for_exit "lua.*sketchybarrc" 5; then
  echo "WARNING: Lua workers didn't exit gracefully, forcing..."
fi
```

#### 3. Force-Kill Loop (nicht einzeln!)
```bash
MAX_ATTEMPTS=10
attempt=0
while [ $attempt -lt $MAX_ATTEMPTS ]; do
  if ! pgrep -f "lua.*sketchybarrc" > /dev/null 2>&1; then
    echo "All Lua processes terminated successfully"
    break
  fi

  echo "Attempt $((attempt+1))/$MAX_ATTEMPTS: Killing Lua zombies..."
  pkill -9 -f "lua.*sketchybarrc" 2>/dev/null
  sleep 1
  attempt=$((attempt + 1))
done
```

#### 4. Lock-File Verification
```bash
# Remove lock file
rm -f /tmp/sketchybar_$USER.lock 2>/dev/null

# Verify lock file is gone
if [ -e /tmp/sketchybar_$USER.lock ]; then
  echo "ERROR: Lock file still exists!"
  exit 1
fi
```

#### 5. Pre-Flight Check Before Restart
```bash
# Final verification before restart
if [ -e /tmp/sketchybar_$USER.lock ]; then
  echo "ERROR: Lock file reappeared!"
  exit 1
fi

if pgrep -f "lua.*sketchybarrc" > /dev/null 2>&1; then
  echo "ERROR: Lua processes reappeared!"
  exit 1
fi

# Nur DANN starten:
/opt/homebrew/bin/sketchybar &
```

#### 6. Post-Start Process Count Check
```bash
# Count sketchybar + lua processes (should be exactly 2)
PROCS=$(ps aux | grep -E '[s]ketchybar|[l]ua.*sketchybar' | wc -l)

if [ "$PROCS" -eq 2 ]; then
  echo "✅ Process count correct (2)"
elif [ "$PROCS" -gt 2 ]; then
  echo "⚠️  WARNING: Too many processes ($PROCS)!"
  # Notification aber KEIN exit 1
fi
```

## Testing

### Test 1: Apple-Logo Doppelklick
```bash
# Vor Fix: Error-Dialog "Zombie-Prozesse"
# Nach Fix: ✅ "Restart erfolgreich! 14 Workspaces, 2 Prozesse."
```

### Test 2: Manuelle Restarts (schnell hintereinander)
```bash
./configs/sketchybar/plugins/restart_services.sh
sleep 1
./configs/sketchybar/plugins/restart_services.sh
sleep 1
./configs/sketchybar/plugins/restart_services.sh

# Erwartung: Keine Zombies, immer 2 Prozesse
```

### Test 3: Process Count Verification
```bash
ps aux | grep -E '[s]ketchybar|[l]ua.*sketchybar' | wc -l
# Erwartung: 2 (1x daemon, 1x lua worker)
```

## Files Updated

- `configs/sketchybar/plugins/restart_services.sh` - Robuste Restart-Logic (Fallback)
- `configs/sketchybar/plugins/apple_click_handler.sh` - Apple-Logo Doppelklick (ruft jetzt `scripts/refresh-aerospace-sketchy.sh` auf)
- `scripts/restart_services.sh` - Sync'd from plugins/
- `scripts/apple_click_handler.sh` - Sync'd from plugins/
- `scripts/refresh-aerospace-sketchy.sh` - Sanfter Refresh (Symlink-Check, reload-config, Sketchybar-Reload)

## Lessons Learned

1. **Brew services supervision is shallow** - Nur Parent-PID, keine Children
2. **Lua workers can outlive daemon** - Event-Loop hält sie am Leben
3. **Lock files need explicit verification** - Nicht nur löschen, auch prüfen
4. **Force-kill needs loops** - Einzelner `pkill -9` reicht nicht bei Race Conditions
5. **Pre-flight checks critical** - Vor Restart verifizieren dass alles sauber ist

## Performance

- **Wait Zeit:** Max 5s für graceful, 10s für force-kill loop
- **Total Restart:** ~8-12 Sekunden (vorher: instant aber fehlerhaft)
- **Tradeoff:** Langsamer aber zuverlässig

## Monitoring

```bash
# Check Lock-File
lsof /tmp/sketchybar_$USER.lock

# Check Prozesse
ps aux | grep -E '[s]ketchybar|[l]ua.*sketchybar'

# Check Log
tail -f /tmp/sketchybar_apple_handler.log
```

## Rollback

Falls Probleme:
```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy
git checkout HEAD~1 configs/sketchybar/plugins/restart_services.sh
git checkout HEAD~1 configs/sketchybar/plugins/apple_click_handler.sh
```

## Status: PRODUCTION ✅

- Getestet: 2025-11-12 (Refresh-Variante nachgezogen 2025-11-XX)
- Apple-Logo Doppelklick: ✅ Führt sanften Refresh aus (kein Force-Kill)
- Harte Restart-Skripte bleiben als Fallback erhalten
- Process Count stabil: ✅ (2 Prozesse)
