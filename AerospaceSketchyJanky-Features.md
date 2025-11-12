# Aerospace + Sketchybar + JankyBorders – Feature Overview

Diese Datei fasst alle entscheidenden Funktionen und Einstellungen zusammen, die für das finale Setup relevant sind. Sie dient als Referenz, falls das Projekt einmal komplett entfernt und anschließend neu, schlank und korrekt aufgesetzt werden soll.

---

## 1. Systemüberblick
- **Window Manager:** Aerospace (aktuell `~/.aerospace.toml` via Symlink)
- **Status Bar:** Sketchybar (Lua-Setup unter `configs/sketchybar/`)
- **Borders:** JankyBorders (gestartet über `scripts/start-borders.sh`)
- **Key Remapping:** Karabiner (Hyper-Key CapsLock → ⌃⌥⇧, Hyper+ = ⌃⌥⇧⌘)
- **Refresh-Button:** Apple-Logo-Doppelklick (`apple_click_handler.sh` → `scripts/refresh-aerospace-sketchy.sh`) lädt Configs neu, ohne Prozesse zu killen. Voller Restart nur noch per `restart_services.sh` falls nötig.

---

## 2. Shortcuts & Funktionen (QWERTZ-Layout)

### Workspace-Navigation
| Aktion | Shortcut |
|--------|----------|
| Q / W / E / R / T wechseln | `Hyper + Q/W/E/R/T` |
| A / S / D / F / G wechseln | `Hyper + A/S/D/F/G` |
| Vorheriger / nächster Workspace | `Hyper + J` / `Hyper + L` (via `workspace-prev.sh` / `workspace-next.sh`) |
| Fenster → Workspace (QWERT oben) | `Hyper+ + Q/W/E/R/T` |
| Fenster → Workspace (ASDFG unten) | `Hyper+ + A/S/D/F/G` |
| Fenster → vorherigen / nächsten Workspace | `Hyper+ + J/L` (via `move-prev-follow.sh` / `move-next-follow.sh`) |
| Overflow-Workspaces | Automatisch X/Y/Z via Smart-Move (`Hyper + I`) |

### Fokus, Swap & Layout
- Fenster im Workspace zyklisch wechseln: `Hyper + N` (vorheriges) / `Hyper + M` (nächstes); Fokus hoch/runter via `Hyper + ↑/↓`
- Fenster tauschen: `Hyper+ + Pfeile` (links/rechts/hoch/runter)
- Layouts direkt setzen: `Hyper + H` (Tiles horizontal), `Hyper + V` (Tiles vertical), `Hyper + K` (Accordion ↔ vorheriger Tiles-Zustand)
- Fullscreen `Hyper + Enter`, Float-Toggle `Hyper+ + Enter`
- Balance `Hyper+ + O`, Rotationen `Hyper + ,` / `Hyper + .`

### Multi-Monitor & Management
- Smart Window-to-Monitor `Hyper + I` (erstellt ggf. passenden Workspace auf Zielmonitor)
- Workspace-to-Monitor `Hyper + O`
- Monitor-Fokus: `Hyper + U/P`, Workspace-Shift zu Monitor: `Hyper+ + U/P`
- Overflow-Workspaces werden bei Bedarf automatisch erzeugt; Hyper + Z entfernt den aktuellen Workspace

---

## 3. Sketchybar Setup

### Struktur
- **Dateien:** `configs/sketchybar/`
- **Einstieg:** `sketchybarrc` → `init.lua`
- **Wichtige Module:**
  - `helpers/aerospace_batch.lua` – Batch-Queries (Workspaces, Windows, Monitore)
  - `items/spaces.lua` – QWERTZ-Workspace-Leiste (Screenshot-Layout)
  - `helpers/app_icons.lua` – Icon-Zuordnung pro App
  - `plugins/restart_services.sh` & `apple_click_handler.sh` – Restart & Health-Checks

### Workspace-Leiste (Screenshot)
- Reihenfolge: `Q W E R T | A S D F G` (Separationsstrich) + Overflow `X/Y/Z`
- Jeder Buchstabe ist das Item-Icon; die Label-Zeile zeigt aktive Apps anhand von SF-Symbolen (Mapping in `app_icons.lua`).
- Klick → `aerospace workspace <LETTER>`
- Highlight via `aerospace_workspace_change` Event; Maus-Over Popup optional.

### Restart & Health-Check
- Apple-Logo-Doppelklick startet `scripts/refresh-aerospace-sketchy.sh`: prüft Symlinks, führt `aerospace reload-config`, lädt Sketchybar neu und triggert die Events – **ohne** Prozesse zu killen. Der alte „Hard Restart“ bleibt über `scripts/restart_services.sh` verfügbar, wird aber nur noch bei echten Hängern benötigt.
- Health-Check zählt **nur echte** Sketchybar/Lua-Prozesse, wartet bis beide laufen, speichert Prozessliste bei Warnungen nach `/tmp/sketchybar_process_dump.log`.
- Workspaces werden nach dem Start gezählt (Erwartung ≥10 QWERTZ-Workspaces, Overflow optional); Warnung bei Abweichung.

---

## 4. JankyBorders & Gaps
Konfiguriert in `scripts/start-borders.sh` + Aerospace-Gaps.

```toml
[gaps]
inner.horizontal = 0
inner.vertical   = 0
outer.left       = 0
outer.top        = 0
outer.right      = 0
outer.bottom     = 30  # Platz für Sketchybar
```

JankyBorders wird nach Aerospace-Start über `scripts/start-borders.sh` initialisiert (siehe `after-startup-command` in `configs/aerospace.toml`). Damit bleiben Rahmen sauber sichtbar, ohne dass Sketchybar abgeschnitten wird.

---

## 5. Wichtige Skripte & Pfade (nur falls diese noch benötigt werden)

| Zweck | Pfad |
|-------|------|
| Refresh (Apple-Logo) | `configs/sketchybar/plugins/apple_click_handler.sh` → `scripts/refresh-aerospace-sketchy.sh` |
| (Optional) Hard Restart + Health-Check | `configs/sketchybar/plugins/restart_services.sh` |
| Manuelles Restart-Script | `scripts/restart_services.sh` |
| Smart Move/Follow | `scripts/move-next-follow.sh`, `scripts/move-prev-follow.sh` |
| Fokus & Center Maus | `scripts/focus-and-center.sh` |
| Borders Start | `scripts/start-borders.sh` |
| Symlink-Verify (muss grün sein!) | `scripts/verify-symlinks.sh` |

**Einzige Aerospace-Config:**  
- Bearbeitet wird ausschließlich `configs/aerospace.toml` im Repo.  
- `~/.aerospace.toml` ist nur ein Symlink auf genau diese Datei.  
- Vor jedem Edit/Restart `scripts/verify-symlinks.sh` ausführen oder manuell prüfen:
  ```bash
  ls -la ~/.aerospace.toml
  # Erwartet: lrwxr-xr-x … -> ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml
  ```
  Falls nicht: `rm ~/.aerospace.toml && ln -s ~/MyCloud/TOOLs/aerospace+sketchy/configs/aerospace.toml ~/.aerospace.toml`

Sketchybar läuft analog: `~/.config/sketchybar` ist ein Symlink auf `configs/sketchybar/`. Nur so existiert niemals eine zweite Config-Version.

---

## 6. Clean Reinstall Checkliste
1. **Backup:** `scripts/verify-symlinks.sh` (Symlink-Status), `brew services list` sichern.
2. **Deactivate:** `scripts/restart_services.sh --stop-only` (falls hinzugefügt) oder manuell `pkill -9`.
3. **Remove:** Projektordner löschen (oder verschieben), LaunchAgents `homebrew.mxcl.sketchybar.plist` entladen, JankyBorders ggf. per `brew services stop borders`.
4. **Reinstall Steps (Kurzfassung):**
   - Repo neu klonen oder entpacken.
   - Symlinks setzen: `~/.aerospace.toml` → `configs/aerospace.toml`, `~/.config/sketchybar` → `configs/sketchybar`.
   - `brew services restart sketchybar`, Apple-Logo doppelklicken zur Verifikation.
   - Ggf. `./scripts/start-borders.sh` in Login Items aufnehmen.
5. **Validation:** Apple-Logo-Doppelklick ausführen, Health-Check = 2 Prozesse / ≥10 Workspaces, QWERTZ-Leiste & App-Icons sichtbar.

---

## 7. Troubleshooting (Kurzfassung)
- **Lock-File / Zombies:** `pkill -9 sketchybar lua`, `rm /tmp/sketchybar_$USER.lock`, `brew services restart sketchybar`.
- **Config wirkt nicht:** `ls -la ~/.aerospace.toml` (Symlink?), `aerospace reload-config`.
- **Nur alte Workspaces:** Apple-Logo-Refresh ausführen → triggert `aerospace reload-config` + Sketchybar-Reload. Hard-Restart nur bei echten Prozesshängern nötig.
- **Restart-Warnung „0/1 Prozesse“:** `/tmp/sketchybar_process_dump.log` prüfen; bei Bedarf Wartezeit erhöhen oder `brew services restart sketchybar` manuell ausführen.

---

Diese Datei fasst alle benötigten Informationen zusammen, um das Setup jederzeit reproduzierbar aufzubauen oder gezielt zu debuggen. Für detaillierte Schrittfolgen siehe zusätzlich `README.md`, `PLAN.md`, `SHORTCUTS.md` und die Skript-Kommentare. 
