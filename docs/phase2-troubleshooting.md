# Phase 2 Troubleshooting Log

## Problem: "Displays have separate spaces: false"

**Datum:** 2025-11-11 10:30 - 11:00
**Phase:** 2 - Aerospace Installation
**Status:** IN PROGRESS

---

## Symptome

### Fehler-Meldung
```
##### AeroSpace Runtime Error #####

Message:
Version: 0.19.2-Beta
Git hash: d246f250468fc9d427a2eb901d56794af7ac6609
macOS version: Version 26.0.1 (Build 25A362)
Monitor count: 2
Displays have separate spaces: false

Coordinate: AppBundle/initAppBundle.swift:15:14 initAppBundle()
```

### Beobachtungen
1. **Aerospace installiert:** 0.19.2-Beta (via Homebrew)
2. **macOS Einstellung:**
   - System Settings → Desktop & Dock → Mission Control
   - ✅ "Monitore verwenden verschiedene Spaces" = **AKTIVIERT**
   - Screenshot bestätigt: Option ist ON
3. **Aerospace erkennt:** `false`
4. **Hardware:** 2 Monitore angeschlossen
5. **macOS Version:** Sequoia 26.0.1 (Build 25A362)

---

## Versuchte Lösungen

### Versuch 1: Accessibility Permission
**Annahme:** Permission fehlt → Server startet nicht
**Ergebnis:** Prozess läuft (PID 13588), aber Server antwortet nicht
**Status:** Nicht die Ursache (aber noch zu aktivieren)

### Versuch 2: Aerospace neu starten
**Durchgeführt:**
```bash
killall AeroSpace
open -a AeroSpace
```
**Ergebnis:** Gleicher Fehler

### Versuch 3: Config-Konflikt beheben
**Problem:** Zwei Config-Files gefunden
```
/Users/wolfgang/.aerospace.toml
/Users/wolfgang/.config/aerospace/aerospace.toml
```
**Lösung:**
```bash
mv ~/.config/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml.old-backup
```
**Ergebnis:** Config-Konflikt behoben, aber Separate Spaces Problem bleibt

---

## Analyse

### Wahrscheinliche Ursache
**macOS Sequoia + Aerospace Beta Disconnect**

Die Einstellung "Displays have separate Spaces" ist in macOS aktiviert, aber:
1. macOS Mission Control hat die Änderung nicht vollständig aktiviert
2. Aerospace liest einen veralteten/gecachten Wert
3. Multi-Monitor-Setup verstärkt das Problem

### Ähnliche Issues
- Aerospace GitHub: Verschiedene User berichten von Separate Spaces Problemen
- macOS Sequoia (26.x) hat Mission Control Änderungen
- Workaround: Toggle OFF/ON + Neustart

---

## Geplante Lösung

### Schritt 1: Toggle OFF → ON
```
System Settings → Desktop & Dock → Mission Control
1. ☐ "Monitore verwenden verschiedene Spaces" DEAKTIVIEREN
2. Warten 2-3 Sekunden
3. ☑ "Monitore verwenden verschiedene Spaces" AKTIVIEREN
4. Bestätigen falls macOS Dialog zeigt
```

### Schritt 2: System neu starten
```
Apple-Menü → Restart
```

### Schritt 3: Nach Neustart testen
```bash
# Aerospace sollte automatisch starten (start-at-login = true)
aerospace --version

# Workspaces prüfen
aerospace list-workspaces --all

# Test-Shortcuts
# Alt + 1 → Workspace 1
# Alt + h/l → Focus left/right
```

### Schritt 4: Falls Problem bleibt

**Option A: Aerospace Docs/GitHub Issues checken**
- v0.19.2-Beta spezifische Issues
- macOS Sequoia Workarounds
- Rollback zu älterer Aerospace-Version

**Option B: Rollback zu Yabai**
```bash
./scripts/rollback-to-yabai.sh
```

---

## Notizen

### Alte Aerospace-Config gefunden
- **Location:** `~/.config/aerospace/aerospace.toml`
- **Datum:** 2024-12-10
- **Größe:** 9668 bytes
- **Status:** Umbenannt zu `.old-backup`
- **Anmerkung:** War bereits eine alte Aerospace-Installation vorhanden!

### System-Informationen
- **macOS:** Sequoia 26.0.1 (Build 25A362)
- **Monitors:** 2
- **Aerospace:** 0.19.2-Beta (d246f250468fc9d427a2eb901d56794af7ac6609)
- **Homebrew:** /opt/homebrew (Apple Silicon)

---

## Timeline

**10:30** - Aerospace via Homebrew installiert
**10:33** - Minimal-Config erstellt
**10:33** - Erste Fehler-Meldung: Separate Spaces false
**10:35** - Accessibility Permission Problem erkannt
**10:40** - Prozess läuft, aber Server antwortet nicht
**10:45** - Config-Konflikt entdeckt und behoben
**10:50** - Separate Spaces Einstellung überprüft: WAR BEREITS AKTIVIERT
**10:53** - Zweite Fehler-Meldung: Monitor count: 2, Separate Spaces false
**11:00** - Stand gesichert, Toggle OFF/ON + Neustart geplant

---

## Status: WARTEND AUF NEUSTART

Nächster Schritt: Toggle Separate Spaces OFF → ON, dann Neustart
