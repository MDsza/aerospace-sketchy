# MIGRATIONS-PLAN: Yabai → Aerospace + Sketchybar

**Status:** Phase 2 - IN PROGRESS ⚠️ (Troubleshooting)
**Letzte Aktualisierung:** 2025-11-11 11:00
**Aktueller Schritt:** Phase 2.2 - Displays Separate Spaces Problem

---

## Phasen-Übersicht

| Phase | Status | Beschreibung | Zeit |
|-------|--------|--------------|------|
| 0 | ✅ COMPLETED | Vorbereitung & Dokumentation | 1h |
| 1 | ✅ COMPLETED | Backup & Safety | 30min |
| 2 | 🟡 IN PROGRESS | Aerospace Installation | 30min+ |
| 3 | ⚪ PENDING | Config-Migration | 2-3h |
| 4 | ⚪ PENDING | Sketchybar Anpassung | 1-2h |
| 5 | ⚪ PENDING | Scripts Migration | 2-3h |
| 6 | ⚪ PENDING | Deinstallation (Soft) | 30min |
| 7 | ⚪ PENDING | Testing & Validation | 1-2h |
| 8 | ⚪ PENDING | Dokumentation | 1h |

**Gesamt-Zeit:** ~8-12h
**Rollback:** Jederzeit möglich

---

## PHASE 0: VORBEREITUNG & DOKUMENTATION ✅

**Status:** COMPLETED
**Beginn:** 2025-11-11
**Abgeschlossen:** 2025-11-11

### Aufgaben

- [x] Basis-Projekt analysiert (`~/MyCloud/TOOLs/yabai-skhd-sbar`)
- [x] Aerospace-Capabilities recherchiert
- [x] Migrations-Strategie definiert
- [x] CLAUDE.md erstellt
- [x] README.md erstellt
- [x] PLAN.md erstellt (dieser File)
- [x] SHORTCUTS.md (Transition Cheat Sheet) erstellt
- [x] Workspace-Mapping dokumentiert (in SHORTCUTS.md)
- [x] Breaking-Changes dokumentiert (in PLAN.md + SHORTCUTS.md)

### Erkenntnisse

- Yabai-Setup vollständig analysiert: 40+ Shortcuts, 20 Spaces, Lua-basierte Sketchybar
- Aerospace nutzt eigene virtuelle Workspaces (kein Mission Control)
- KEIN SIP-Disable nötig (großer Vorteil!)
- Karabiner wird BEIBEHALTEN (CapsLock → Hyper)
- SKHD wird durch Aerospace built-in Shortcuts ersetzt

### Ergebnisse

**Dokumentation erstellt:**
- `CLAUDE.md` - Projekt-Kontext für Claude Code (Migrations-Strategie, Tech-Stack, Unterschiede)
- `README.md` - Setup-Anleitung mit Installation, Rollback, Troubleshooting
- `PLAN.md` - Vollständiger Migrations-Plan mit 8 Phasen (dieser File)
- `SHORTCUTS.md` - Transition Cheat Sheet mit Yabai↔Aerospace Mapping (40+ Shortcuts)

**Projekt-Struktur angelegt:**
```
aerospace+sketchy/
├── CLAUDE.md
├── README.md
├── PLAN.md
├── SHORTCUTS.md
├── configs/           (leer, bereit für Phase 3)
├── scripts/           (leer, bereit für Phase 5)
├── backup/            (leer, bereit für Phase 1)
└── docs/              (leer, bereit für Phase 8)
```

### Nächster Schritt

Phase 1 starten: Git Commit + Push yabai-skhd-sbar (Tag: v-yabai-final)

---

## PHASE 1: BACKUP & SAFETY ✅

**Status:** COMPLETED
**Beginn:** 2025-11-11 10:18
**Abgeschlossen:** 2025-11-11 10:28
**Dauer:** ~10 Minuten
**Voraussetzungen:** Phase 0 abgeschlossen

### 1.1 Git Commit + Push yabai-skhd-sbar

```bash
cd ~/MyCloud/TOOLs/yabai-skhd-sbar

# Status prüfen
git status

# Alle Änderungen committen
git add -A
git commit -m "Final Yabai setup v2.7.2 before Aerospace migration

🎯 Migration zu Aerospace+Sketchybar vorbereitet
✅ Production-ready state
📦 Backup vor System-Änderungen

Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Tag erstellen
git tag -a v-yabai-final -m "Final Yabai setup before Aerospace migration"

# Push (WICHTIG!)
git push origin main --tags
```

### 1.2 Homebrew-State sichern

```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy

# Backup-Verzeichnis anlegen
mkdir -p backup

# Brewfile dumpen
brew bundle dump --file=backup/Brewfile.backup --force

# Service-Status
brew services list > backup/services-state-before.txt
launchctl list | grep -E 'yabai|skhd|sketchybar' > backup/launchctl-before.txt
```

### 1.3 Karabiner-Config sichern

```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy

# Karabiner komplett sichern
mkdir -p backup/karabiner-backup
cp -r ~/.config/karabiner/ backup/karabiner-backup/
cp -r ~/Library/Application\ Support/org.pqrs.Karabiner-Elements/ backup/karabiner-backup/app-support/
```

### 1.4 Complete System Backup

```bash
cd ~/MyCloud/TOOLs/yabai-skhd-sbar

# Bestehenden Backup-Script nutzen
./scripts/complete-system-backup.sh

# Archiv prüfen
ls -lh yabai-skhd-sketchybar-backup_*.tar.gz

# WICHTIG: Archiv extern sichern (USB/Cloud)
```

### 1.5 Rollback-Script erstellen

```bash
# Datei: scripts/rollback-to-yabai.sh wird in Phase 1 angelegt
```

### Checkliste Phase 1

- [x] Git commit + push erfolgreich
- [x] Tag `v-yabai-final` erstellt (pushed zu GitHub)
- [x] Brewfile.backup vorhanden
- [x] Service-State gesichert (services-state-before.txt, launchctl-before.txt)
- [x] Karabiner komplett gebackupt (karabiner-backup/)
- [x] Complete-Backup-Archiv erstellt (4.3M komprimiert)
- [x] rollback-to-yabai.sh erstellt

### Ergebnisse Phase 1

**Git Backup:**
- Repository: https://github.com/MDsza/yabai-skhd-sbar.git
- Branch: claude/project-review-011CUWZpX9KMP58bh5XYsDqN
- Tag: v-yabai-final (pushed)
- Commit: 94ce9f6

**Homebrew Backup:**
- Brewfile: `backup/Brewfile.backup`
- Service-State: `backup/services-state-before.txt`
- LaunchAgents: `backup/launchctl-before.txt`

**Karabiner Backup:**
- Config: `backup/karabiner-backup/karabiner.json`
- Assets: `backup/karabiner-backup/assets/`
- Auto-Backups: `backup/karabiner-backup/automatic_backups/`

**Complete System Backup:**
- Location: `~/MyCloud/TOOLs/_TOOLs-BACKUPs/yabai-skhd-sbar/`
- File: `yabai-skhd-sketchybar-backup_2025-11-11_10-22-48.tar.gz`
- Size: 4.3M (komprimiert)
- Includes: Komplettes Projekt + Configs + Service-Status + Restore-Anweisungen

**Rollback-Script:**
- File: `scripts/rollback-to-yabai.sh`
- Executable: ✅
- Features:
  - Aerospace deaktivieren/deinstallieren
  - Yabai+SKHD aus Brewfile installieren
  - Git checkout v-yabai-final
  - Configs restore via symlinks
  - Karabiner restore
  - Services restart
  - Status-Check

### Nächster Schritt

Phase 2: Aerospace Installation
- brew install aerospace
- Accessibility Permissions aktivieren
- LaunchAgent prüfen
- Minimal-Config testen

---

## PHASE 2: AEROSPACE INSTALLATION 🟡

**Status:** IN PROGRESS - Troubleshooting
**Beginn:** 2025-11-11 10:30
**Voraussetzungen:** Phase 1 abgeschlossen, Backups verifiziert

### 2.1 Installation

```bash
# Aerospace installieren
brew install --cask nikitabobko/tap/aerospace

# Version prüfen
aerospace --version
```

### 2.2 Displays Separate Spaces (KRITISCH!)

**⚠️ ERFORDERLICH:** Aerospace benötigt separate Spaces pro Display!

**Manuell durchführen:**
1. System Settings öffnen
2. Desktop & Dock
3. Mission Control section scrollen
4. **Aktivieren:** ☑ "Displays have separate Spaces"
5. **SYSTEM NEU STARTEN** (zwingend erforderlich!)

**Fehler falls nicht aktiviert:**
```
AeroSpace Runtime Error
Displays have separate spaces: false
```

### 2.3 Accessibility Permissions

**Manuell durchführen (NACH Neustart):**
1. System Settings öffnen
2. Privacy & Security → Accessibility
3. Aerospace in Liste finden
4. Checkbox aktivieren

**⚠️ WICHTIG:** Nach jedem Aerospace-Update muss Permission OFF/ON getoggled werden!

### 2.4 LaunchAgent prüfen

```bash
# LaunchAgent sollte automatisch erstellt werden
ls -la ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist

# Falls nicht vorhanden, manuell starten:
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.nikitabobko.aerospace.plist

# Status prüfen
launchctl list | grep aerospace
```

### 2.5 Erste Config (Minimal)

```bash
# Minimal-Config für Test
cat > ~/.aerospace.toml << 'EOF'
# Aerospace Minimal Config (Test)

start-at-login = true

[gaps]
inner.horizontal = 0
inner.vertical = 0
outer.left = 0
outer.bottom = 0
outer.top = 0
outer.right = 0

[mode.main.binding]
alt-h = 'focus left'
alt-l = 'focus right'
alt-1 = 'workspace 1'
EOF

# Aerospace neu laden
aerospace reload-config
```

### 2.5 PRAM Clear (falls Shortcuts nicht funktionieren)

**Manuell durchführen:**
1. Mac herunterfahren
2. Einschalten + sofort Cmd+Opt+P+R halten
3. Warten bis 2× Bootsound / Apfel-Logo 2×
4. Tasten loslassen

### Aktueller Stand Phase 2 (2025-11-11 11:00)

**✅ Erfolgreich durchgeführt:**
- [x] Aerospace 0.19.2-Beta installiert
- [x] Minimal-Config erstellt (`~/.aerospace.toml`)
- [x] Alte Config-Konflikte bereinigt (`.config/aerospace/aerospace.toml.old-backup`)
- [x] Aerospace-Prozess läuft (PID 13588)

**⚠️ AKTUELLES PROBLEM: Displays Separate Spaces**

**Symptom:**
```
AeroSpace Runtime Error
Displays have separate spaces: false
Monitor count: 2
```

**Status:**
- macOS Einstellung: ✅ "Monitore verwenden verschiedene Spaces" = AKTIVIERT
- Aerospace erkennt: ❌ `false`

**Vermutete Ursache:**
- macOS Sequoia (26.0.1) + Aerospace 0.19.2-Beta Disconnect
- Multi-Monitor-Setup (2 Displays)
- Einstellung war bereits aktiviert, aber nicht wirksam

**Geplante Lösung:**
1. Toggle: Einstellung OFF → ON
2. System neu starten
3. Aerospace testen nach Neustart
4. Falls weiterhin Problem: Aerospace Docs/Issues checken oder Rollback erwägen

**Zusätzliche Probleme behoben:**
- [x] Config-Konflikt: Doppelte Config-Files (beide gefunden, eine umbenannt)
- [x] Accessibility Permission: Noch nicht getestet (wartet auf Neustart)

### Checkliste Phase 2

- [x] Aerospace installiert (0.19.2-Beta)
- [ ] Accessibility aktiviert (nach Neustart zu prüfen)
- [ ] LaunchAgent läuft (nach Neustart zu prüfen)
- [ ] Minimal-Config funktioniert (blockiert durch Separate Spaces)
- [ ] Test-Shortcuts (alt-h/l) funktionieren (blockiert)
- [x] Keine SIP-Änderung nötig (bestätigt)

---

## PHASE 3: CONFIG-MIGRATION ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 2 abgeschlossen, Aerospace läuft

### 3.1 Workspace-Setup (Hybrid)

**Mapping:**
```
1-9  → Standard Workspaces (Zahlen)
C    →  Code (VS Code, Terminal, IDEs)
M    →  Music (Spotify, iTunes, Audio)
B    →  Browser (Safari, Firefox, Chrome)
E    → ✉ Email (Mail.app, Outlook)
T    →  Terminal (dediziert Shell-Sessions)
```

### 3.2 Keyboard Shortcuts konvertieren

**Alle 40+ SKHD-Shortcuts → Aerospace TOML**

Kategorien:
- Focus/Swap (Hyper + Pfeile)
- Layouts (Hyper + K)
- Workspaces (Hyper + [1-9,C,M,B,E,T])
- Move Windows (Hyper+ + [1-9,C,M,B,E,T])
- Display Management (Hyper + I/O)
- Service Management

Siehe: SHORTCUTS.md für vollständige Mapping-Tabelle

### 3.3 Window Rules portieren

**Yabai `manage=off` → Aerospace `[[on-window-detected]]`**

```toml
# Beispiel:
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = 'layout floating'

[[on-window-detected]]
if.app-id = 'com.raycast.macos'
if.window-title-regex-substring = 'Settings'
run = 'layout floating'
```

### 3.4 App-Specific Workspace Assignments

```toml
# Spotify → Workspace M
[[on-window-detected]]
if.app-id = 'com.spotify.client'
run = 'move-node-to-workspace M'

# VS Code → Workspace C
[[on-window-detected]]
if.app-id = 'com.microsoft.VSCode'
run = 'move-node-to-workspace C'

# Browser → Workspace B
[[on-window-detected]]
if.app-id = 'com.apple.Safari'
run = 'move-node-to-workspace B'
```

### 3.5 Gaps & Padding

```toml
# Sketchybar-Kompatibilität
[gaps]
inner.horizontal = 0
inner.vertical = 0
outer.left = 0
outer.bottom = 30    # SKETCHYBAR_HEIGHT
outer.top = 0
outer.right = 0
```

### Checkliste Phase 3

- [ ] aerospace.toml Draft erstellt
- [ ] Alle Workspaces definiert (1-9, C, M, B, E, T)
- [ ] Alle Shortcuts konvertiert (40+)
- [ ] Window Rules portiert
- [ ] App-Assignments konfiguriert
- [ ] Gaps/Padding für Sketchybar
- [ ] Config reviewed
- [ ] aerospace reload-config erfolgreich

---

## PHASE 4: SKETCHYBAR ANPASSUNG ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 3 abgeschlossen, Aerospace-Config funktioniert

### 4.1 Aerospace-Integration in Config

```toml
# In ~/.aerospace.toml ergänzen:

after-startup-command = ['exec-and-forget sketchybar']

exec-on-workspace-change = [
  '/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

### 4.2 Spaces Widget umbauen

**Datei:** `configs/sketchybar/items/spaces.lua`

**Änderungen:**
- Von Yabai-Queries → Aerospace-Events
- 20 Spaces → 14 Spaces (1-9, C, M, B, E, T)
- Icon-Mapping für Buchstaben-Workspaces
- Highlighting aktiver Workspace

### 4.3 Event-Handler

**Neues Script:** `configs/sketchybar/plugins/aerospace_workspace_change.sh`

```bash
#!/bin/bash
# Triggered von Aerospace bei Workspace-Wechsel

FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE"

# Alle Spaces auf inactive setzen
for space in 1 2 3 4 5 6 7 8 9 C M B E T; do
  sketchybar --set "space.$space" icon.font.style="Regular" icon.font.size=12
done

# Aktiven Space highlighten
sketchybar --set "space.$FOCUSED_WORKSPACE" \
  icon.font.style="Black" \
  icon.font.size=14
```

### 4.4 Temporäres Bridge-Script (optional)

Falls schrittweise Migration:

**Datei:** `scripts/aerospace-yabai-bridge.sh`

Mappt Aerospace-Events auf alte Yabai-Trigger für Kompatibilität während Testing.

### 4.5 Workspace-Labels

```lua
-- spaces.lua
local workspace_icons = {
  ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5",
  ["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9",
  ["C"] = "", -- Code
  ["M"] = "", -- Music
  ["B"] = "", -- Browser
  ["E"] = "✉", -- Email
  ["T"] = ""  -- Terminal
}
```

### Checkliste Phase 4

- [ ] Aerospace-Integration in Config
- [ ] Spaces Widget umgebaut
- [ ] Event-Handler Script erstellt
- [ ] Workspace-Labels definiert
- [ ] Sketchybar zeigt korrekte Workspaces
- [ ] Highlighting funktioniert
- [ ] App-Icons werden angezeigt
- [ ] Performance OK (keine Lags)

---

## PHASE 5: SCRIPTS MIGRATION ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 4 abgeschlossen, Sketchybar funktioniert

### 5.1 Kritische Scripts neu implementieren

#### **Space Explosion/Implosion**

**Status:** Aerospace hat andere Layout-Logik
- **Alternative:** Layouts per Shortcut wechseln (tiles/accordion)
- **Script:** Eventuell `move-all-to-workspace.sh` für ähnliche Funktion

#### **Window Movement**

**Status:** Aerospace-native Commands nutzen
- `move left/right/up/down`
- `move-node-to-workspace X`
- `move-node-to-monitor next/prev`

#### **Layout Toggle**

**Yabai:** BSP ↔ Stack
**Aerospace:** tiles ↔ accordion ↔ floating

**Script:** `scripts/layout-cycle.sh`

```bash
#!/bin/bash
# Cycle: tiles → accordion → floating → tiles

current=$(aerospace list-workspaces --focused)
# TODO: Implementierung
```

#### **Display Circular**

**Aerospace Command:** `move-node-to-monitor next`

Bereits built-in, kein separates Script nötig.

### 5.2 Obsolete Scripts

**Nicht mehr benötigt:**
- `window-move-next-circular.sh` → Aerospace-Shortcuts
- `window-move-prev-circular.sh` → Aerospace-Shortcuts
- `fix-space-associations.sh` → Nicht nötig (virtuelle Workspaces)
- `space-explode-impl.sh` → Layout-Logik anders
- `space-implode.sh` → Layout-Logik anders

**Behalten:**
- `sketchybar-reset.sh` → Funktioniert weiter
- `backup-configs.sh` → Anpassen für Aerospace
- `restore-configs.sh` → Anpassen für Aerospace

### 5.3 Neue Scripts

**Anlegen:**
- `scripts/rollback-to-yabai.sh` (bereits in Phase 1)
- `scripts/aerospace-yabai-bridge.sh` (optional, Phase 4)
- `scripts/layout-cycle.sh` (Layout-Toggle)
- `scripts/backup-aerospace-config.sh`

### Checkliste Phase 5

- [ ] Layout-Cycle Script implementiert
- [ ] Display-Management getestet (built-in)
- [ ] Obsolete Scripts archiviert
- [ ] Neue Scripts erstellt
- [ ] Backup-Scripts aktualisiert
- [ ] Alle Workflows funktional

---

## PHASE 6: DEINSTALLATION (SOFT) ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 5 abgeschlossen, alle Workflows funktionieren

### 6.1 Services stoppen (Soft-Disable)

```bash
# Yabai stoppen
brew services stop yabai

# SKHD stoppen
brew services stop skhd

# Services-Status prüfen
brew services list | grep -E 'yabai|skhd|sketchybar'

# Sketchybar sollte WEITER LAUFEN!
```

**⚠️ WICHTIG:** Binaries NICHT deinstallieren (Soft-Disable für 2 Wochen)!

### 6.2 Configs archivieren

```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy

# Archive erstellen
mkdir -p backup/old-configs
cp ~/.yabairc backup/old-configs/yabairc.backup
cp ~/.skhdrc backup/old-configs/skhdrc.backup

# Symlinks entfernen (optional)
# Falls Aerospace stört:
# rm ~/.yabairc ~/.skhdrc
```

### 6.3 LaunchAgents deaktivieren (optional)

```bash
# Falls Aerospace aus Versehen Yabai startet:
launchctl bootout gui/$(id -u)/com.koekeishiya.yabai
launchctl bootout gui/$(id -u)/com.koekeishiya.skhd

# Später reaktivieren mit:
# launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.koekeishiya.yabai.plist
```

### 6.4 Nach 2 Wochen: Hard-Remove (optional)

**NUR wenn Aerospace zu 100% funktioniert!**

```bash
# SKHD komplett entfernen
brew uninstall skhd

# Yabai entfernen (optional)
# brew uninstall yabai

# Configs löschen (BACKUP PRÜFEN!)
# rm ~/.yabairc ~/.skhdrc
```

### Checkliste Phase 6

- [ ] Yabai service gestoppt
- [ ] SKHD service gestoppt
- [ ] Configs archiviert
- [ ] System läuft nur mit Aerospace
- [ ] Keine Konflikte/Fehler
- [ ] Rollback getestet
- [ ] Nach 2 Wochen: Hard-Remove (optional)

---

## PHASE 7: TESTING & VALIDATION ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 6 abgeschlossen, System läuft mit Aerospace

### 7.1 Funktions-Tests

#### **Keyboard Shortcuts**
- [ ] Alle Focus-Shortcuts (Hyper + Pfeile)
- [ ] Alle Swap-Shortcuts (Hyper+ + Pfeile)
- [ ] Layout-Toggle (Hyper + K)
- [ ] Workspace-Switch (Hyper + [1-9,C,M,B,E,T])
- [ ] Window-Movement (Hyper+ + [1-9,C,M,B,E,T])
- [ ] Display-Management (Hyper + I)

#### **Workspaces**
- [ ] Workspace 1-9 funktionieren
- [ ] Workspace C (Code) funktioniert
- [ ] Workspace M (Music) funktioniert
- [ ] Workspace B (Browser) funktioniert
- [ ] Workspace E (Email) funktioniert
- [ ] Workspace T (Terminal) funktioniert
- [ ] Automatische App-Zuordnung funktioniert

#### **Window Management**
- [ ] Tiling korrekt (tiles layout)
- [ ] Accordion funktioniert
- [ ] Floating funktioniert
- [ ] Focus follows window
- [ ] Window-Swap funktioniert
- [ ] Resizing funktioniert

#### **Sketchybar**
- [ ] Workspace-Anzeige korrekt
- [ ] Highlighting aktiver Workspace
- [ ] App-Icons werden angezeigt
- [ ] Alle Widgets funktionieren (CPU, Memory, Battery, etc.)
- [ ] Claude-Notifier funktioniert
- [ ] Performance OK (keine Lags)

### 7.2 Multi-Monitor Tests

- [ ] Display anschließen → Layout korrekt
- [ ] Display trennen → Windows auf Main-Display
- [ ] Fenster über Displays bewegen
- [ ] Workspace-Zuordnung bei Display-Wechsel
- [ ] Sketchybar auf allen Displays
- [ ] Focus zwischen Displays

### 7.3 Input-Device Tests

- [ ] Interne Tastatur
- [ ] Externe Tastatur (USB)
- [ ] Externe Tastatur (Bluetooth)
- [ ] Karabiner-Hyper funktioniert auf allen Devices
- [ ] Lid-Close/Open mit externem Display
- [ ] Hot-Plug USB-Tastatur

### 7.4 Edge Cases

- [ ] Native Fullscreen Apps (kein Aerospace-Management)
- [ ] System Settings (floating)
- [ ] Floating Windows (Minimize-Verhalten)
- [ ] App-Crashes (Window-Recovery)
- [ ] Aerospace-Crash (Service-Recovery)
- [ ] macOS-Update (Accessibility neu setzen)

### 7.5 Performance-Tests

- [ ] CPU-Usage idle (<5%)
- [ ] Memory-Usage (<200MB)
- [ ] Battery-Drain akzeptabel (versteckte Fenster!)
- [ ] Sketchybar Update-Rate OK
- [ ] Keine UI-Freezes
- [ ] Schnelles Workspace-Switching

### Checkliste Phase 7

- [ ] Alle Funktions-Tests bestanden
- [ ] Multi-Monitor stabil
- [ ] Alle Input-Devices funktionieren
- [ ] Edge Cases behandelt
- [ ] Performance akzeptabel
- [ ] Keine Show-Stopper gefunden
- [ ] Workflow produktiv nutzbar

---

## PHASE 8: DOKUMENTATION ⚪

**Status:** PENDING
**Voraussetzungen:** Phase 7 abgeschlossen, System produktiv

### 8.1 Finale Dokumentation

#### **README.md aktualisieren**
- [ ] Installation-Section finalisieren
- [ ] Testing-Ergebnisse dokumentieren
- [ ] Known Issues eintragen
- [ ] Troubleshooting erweitern

#### **SHORTCUTS.md finalisieren**
- [ ] Vollständige Mapping-Tabelle
- [ ] Muscle-Memory-Tipps
- [ ] Häufige Fehler

#### **Breaking Changes Liste**
- [ ] `docs/breaking-changes.md` erstellen
- [ ] Alle Workflow-Änderungen dokumentieren
- [ ] Migration-Notes

#### **Workspace-Mapping**
- [ ] `docs/workspace-mapping.md` erstellen
- [ ] App-Zuordnungen dokumentieren
- [ ] Best Practices

### 8.2 Config-Dokumentation

#### **Aerospace-Config kommentieren**
- [ ] Alle Sections erklärt
- [ ] Shortcuts dokumentiert
- [ ] Window Rules erläutert

#### **Sketchybar-Config kommentieren**
- [ ] Event-Integration dokumentiert
- [ ] Widget-Anpassungen erklärt
- [ ] Performance-Optimierungen beschrieben

### 8.3 Migrations-Notizen

#### **Lessons Learned**
- [ ] Was lief gut?
- [ ] Was war problematisch?
- [ ] Was würde ich anders machen?

#### **Für andere Nutzer**
- [ ] Empfehlungen für ähnliche Migrations
- [ ] Häufige Stolperfallen
- [ ] Timeline realistisch?

### 8.4 Backup & Archivierung

#### **Finales Backup**
```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy

# Complete Backup
tar -czf aerospace-sketchybar-final_$(date +%Y-%m-%d_%H-%M-%S).tar.gz \
  configs/ scripts/ backup/ docs/ *.md

# Git commit
git add -A
git commit -m "Migration completed: Aerospace + Sketchybar productive"
git tag v1.0-aerospace
git push origin main --tags
```

#### **Yabai-Projekt archivieren**
```bash
cd ~/MyCloud/TOOLs/yabai-skhd-sbar

# Final commit
git add -A
git commit -m "Archived: Replaced by Aerospace (see aerospace+sketchy)"
git tag v-archived
git push origin main --tags

# README updaten mit Hinweis auf neues Projekt
```

### Checkliste Phase 8

- [ ] README.md finalisiert
- [ ] SHORTCUTS.md komplett
- [ ] Breaking-Changes dokumentiert
- [ ] Workspace-Mapping dokumentiert
- [ ] Configs kommentiert
- [ ] Lessons Learned geschrieben
- [ ] Finales Backup erstellt
- [ ] Git committed & pushed
- [ ] Yabai-Projekt archiviert

---

## ROLLBACK-STRATEGIE

### Soft-Rollback (empfohlen erste 2 Wochen)

```bash
cd ~/MyCloud/TOOLs/aerospace+sketchy
./scripts/rollback-to-yabai.sh
```

**Effekt:**
1. Aerospace deaktiviert (Binaries bleiben)
2. Yabai+SKHD services restart
3. Configs restored aus backup/
4. Sketchybar neu geladen
5. System wie vor Migration

**Dauer:** ~5 Minuten

### Hard-Rollback (falls Aerospace komplett unbrauchbar)

```bash
# 1. Im Basis-Projekt
cd ~/MyCloud/TOOLs/yabai-skhd-sbar
git checkout v-yabai-final

# 2. Configs restore
./scripts/restore-configs.sh

# 3. Homebrew-State
cd ~/MyCloud/TOOLs/aerospace+sketchy
brew bundle install --file=backup/Brewfile.backup

# 4. Karabiner restore
cp -r backup/karabiner-backup/karabiner/ ~/.config/
cp -r backup/karabiner-backup/app-support/ ~/Library/Application\ Support/org.pqrs.Karabiner-Elements/

# 5. Services restart
brew services restart yabai
brew services restart skhd
brew services restart sketchybar

# 6. Aerospace entfernen (optional)
brew uninstall --cask aerospace
```

**Dauer:** ~15 Minuten

---

## KOMPONENTEN-ENTSCHEIDUNGEN

| Komponente | Status | Begründung |
|------------|--------|------------|
| **Karabiner** | ✅ BEHALTEN | CapsLock→Hyper unverzichtbar, macOS kann es nicht nativ |
| **SKHD** | ❌ ENTFERNEN | Aerospace hat built-in Shortcuts |
| **Yabai** | ❌ SOFT-DISABLE | Nach 2 Wochen Success: Entfernen |
| **Sketchybar** | ✅ BEHALTEN | Mit Anpassungen für Aerospace-Events |
| **Scripts** | 🔄 MIGRIEREN | Teilweise obsolet, teilweise neu implementieren |

---

## TIMELINE & MEILENSTEINE

### Woche 1
- [ ] Phase 0-3 abgeschlossen (Vorbereitung, Backup, Installation, Config)
- [ ] Aerospace läuft parallel zu Yabai
- [ ] Testing in sicherer Umgebung

### Woche 2
- [ ] Phase 4-5 abgeschlossen (Sketchybar, Scripts)
- [ ] Yabai/SKHD soft-disabled
- [ ] Produktiver Einsatz beginnt

### Woche 3-4
- [ ] Phase 6-7 abgeschlossen (Testing, Validation)
- [ ] Alle Edge Cases getestet
- [ ] Entscheidung: Weiter mit Aerospace oder Rollback

### Nach 2 Wochen produktivem Einsatz
- [ ] Phase 8 abgeschlossen (Dokumentation)
- [ ] Hard-Remove Yabai/SKHD (optional)
- [ ] Migration offiziell abgeschlossen

---

## BEKANNTE PROBLEME & LÖSUNGEN

### Problem: Shortcuts funktionieren nach Installation nicht

**Lösung:** PRAM Clear
```
Mac neustarten + Cmd+Opt+P+R halten bis 2× Bootsound
```

### Problem: Accessibility-Fehler nach Update

**Lösung:** Toggle OFF/ON
```
System Settings → Privacy & Security → Accessibility → Aerospace (OFF → ON)
```

### Problem: Sketchybar zeigt keine Workspaces

**Lösung:** Event-Integration prüfen
```bash
sketchybar --query bar
sketchybar --reload
aerospace reload-config
```

### Problem: Battery-Drain erhöht

**Ursache:** Versteckte Fenster rendern weiter (Aerospace-Design)

**Lösung:** Minimieren statt Verstecken, Apps explizit quitten

---

## RESSOURCEN & LINKS

### Dokumentation
- **Aerospace Guide:** https://nikitabobko.github.io/AeroSpace/guide
- **Commands Reference:** https://nikitabobko.github.io/AeroSpace/commands
- **Goodies:** https://nikitabobko.github.io/AeroSpace/goodies

### Community
- **GitHub:** https://github.com/nikitabobko/AeroSpace
- **Dotfiles:** GitHub suche "aerospace sketchybar dotfiles"

### Basis-Projekt
- **Location:** ~/MyCloud/TOOLs/yabai-skhd-sbar
- **Version:** v2.7.2 (v-yabai-final)
- **Backup:** yabai-skhd-sketchybar-backup_*.tar.gz

---

## NOTIZEN

### 2025-11-11 - Projekt gestartet
- Basis-Projekt analysiert
- Aerospace recherchiert
- Migrations-Strategie definiert
- Dokumentation erstellt (CLAUDE.md, README.md, PLAN.md)
- Nächster Schritt: SHORTCUTS.md erstellen

---

**Status-Legende:**
- 🟢 IN PROGRESS - Aktuell in Arbeit
- ⚪ PENDING - Noch nicht begonnen
- ✅ COMPLETED - Abgeschlossen
- ⚠️ BLOCKED - Blockiert (Grund dokumentieren)
- ❌ FAILED - Fehlgeschlagen (Rollback oder Alternative)

---

*Dieser Plan wird nach jeder Phase aktualisiert!*
