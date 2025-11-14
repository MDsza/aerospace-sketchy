# ToDos

# Offen

Noch YXCV dazu als neue Spaces.


---


Findings Codex_alt
Findings

High – configs/aerospace.toml (lines 24-32) still executes sketchybar via after-startup-command, even though the docs and operational scripts manage the bar through brew services. This double‑start path is a prime suspect for the lock‑file/zombie issues you documented, because every Aerospace launch spawns a second Sketchybar instance before the service copy has released its lock. Decide on a single owner (either Brew or Aerospace) and drop the other start hook to avoid race conditions.
High – The restart health check in configs/sketchybar/plugins/restart_services.sh (lines 179-188) hardcodes an expectation of ≥14 workspaces (“1‑9,E,T,C,B,M”). The production layout now uses the fixed QWERTZ set plus X/Y/Z (13 entries total), so every clean restart raises a false warning and notification. Make the threshold dynamic (e.g., count configured QWERTZ items) or lower it to 13 so real workspace loss is not drowned out by false positives.
Medium – All CPU telemetry only parses the %user column from top, yet the widget and documentation describe “total (user + system)” load. See configs/sketchybar/helpers/update_manager.lua (lines 96-102) and the fallback in configs/sketchybar/items/widgets/cpu.lua (lines 82-90). The graph and popup therefore under-report whenever system time is high (e.g., I/O, kernel tasks). Parse both %user and %sys (columns 3 and 5) and sum them before caching/pushing to keep the visuals honest.
Medium – configs/sketchybar/start_dual_bars.sh (lines 16-27) can’t work: it references an init_dual.lua file that no longer exists and prints/saves $TOP_PID/$BOTTOM_PID variables that are never assigned (only BAR_PID is set). Anyone running it will just spawn one instance and record empty PID files. Either remove this script or update it to the current single‑bar architecture.
Low – The menu bridge silently drops one slot. In configs/sketchybar/items/menus.lua (lines 45-54) the loop condition uses if id < max_items even though max_items is 15, so the 15th menu entry can never be drawn. Switching the guard to <= (or pre‑decrementing max_items) lets you actually display the configured number of menu items.
Next Steps

Decide whether Brew or Aerospace owns Sketchybar startup and remove the redundant path; that should also simplify the zombie troubleshooting docs.
Patch the restart script and CPU collectors as noted, then run your usual Apple‑logo soft refresh to verify the warnings disappear.
If start_dual_bars.sh is obsolete, delete it or mark it clearly so it doesn’t confuse future automation.
After code tweaks, re-run scripts/verify-symlinks.sh and a quick sketchybar --reload to confirm the bar comes back cleanly.



# Erledigt

- Programmname und App-Menue Icon weg

- Karusell beim Fenster-Wechsel nicht doch möglich

- Apple-Logo-Toggle Switch

Ich brauche einen Implementierungsplan, aber noch keine Codeänderung:

Ziel:
- Aktuell blendet Sketchybar leere Workspaces komplett aus, und `workspace-next.sh` / `workspace-prev.sh` (Hyper+N/M) überspringen Leerplätze.
- Ich möchte leere Workspaces wieder anzeigen, aber die Navigation soll sie erst berücksichtigen, sobald mindestens ein Fenster auf diesem Workspace liegt. Kurz: Sichtbar ja, anspringbar per Hyper+N/M erst nach „befüllt“.

Bitte liefere einen detaillierten Plan mit folgenden Punkten:
1. Welche Anpassungen sind in `configs/sketchybar/items/spaces.lua` nötig, damit leere Workspaces wieder angezeigt, aber klar als „empty“ markiert werden?
2. Wie erweitern wir `workspace-next.sh` und `workspace-prev.sh`, damit sie weiterhin belegte Workspaces bevorzugen – aber sobald ein bisher leerer Workspace ein Fenster bekommt, taucht er automatisch in der Hyper+N/M-Reihenfolge auf?
3. Welche Events/Aerospace-Abfragen nutzen wir dafür (z.B. `aerospace list-windows`)? Bitte mit Fokus auf Performance (keine 10 Einzelqueries).
4. Testszenarien, um sicherzustellen, dass leere Workspaces zwar sichtbar sind, aber erst beim „Befüllen“ in der Navigation landen.

Nur Plan, keine Umsetzung.