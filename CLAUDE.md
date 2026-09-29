# Hut ist gut! – Projektregeln

Godot 4.7 (GDScript), 2D, Hochformat. Ziel: Android & iOS.

## Technik
- Design-Aufloesung 1080 x 1920, Stretch `canvas_items` / `keep_width`:
  Breite ist immer 1080, die Hoehe waechst auf laengeren Geraeten.
  Layout deshalb immer aus `get_viewport_rect().size` berechnen, nie 1920 annehmen.
- Renderer: Mobile. Touch + Maus: `emulate_touch_from_mouse` ist an – Spiel-Input
  nur ueber `InputEventScreenTouch` / `InputEventScreenDrag` behandeln.
- HUD-Controls, die nicht klickbar sind, bekommen `mouse_filter = IGNORE`,
  sonst schlucken sie Touches.
- Android-Zurueck: `quit_on_go_back` ist aus; jede Szene behandelt
  `NOTIFICATION_WM_GO_BACK_REQUEST` selbst (Menue beendet, sonst zurueck ins Menue).
- Godot ist nicht im PATH; der Inhaber oeffnet das Projekt ueber den Projektmanager.

## Struktur
- `scenes/` – Szenen (`menu`, `game`, `hutregal`, `settings`)
- `scripts/` – Spiellogik; `scripts/config.gd` (`Config`) enthaelt ALLE Groessen,
  Farben, Zeiten und Spielwerte. Keine Magic Numbers in anderen Skripten.
- `ui/` – wiederverwendbare UI-Bausteine (ComicButton, ScorePill, Hearts, Sunburst, Theme, Font)
- `autoload/` – `GameState` (Spielstand), `Transition` (Szenenwechsel mit Wisch-Ueberblendung)
- `levels/` – Level-Daten `level_XX.json` (Format siehe unten)
- `assets/` – Comic-SVGs, importiert mit `svg/scale=2.0` (+ Mipmaps).
  Sprite-Skalierung daher immer `gewuenschte_px / (svg_masse * Config.SVG_IMPORT_SCALE)`.

## Level-Format (`levels/level_XX.json`)
```json
{ "rings": [ { "radius_index": 0, "speed": 0.25, "direction": 1,
               "glasses": ["blau", "", "rot", "gelb", "gold"] } ] }
```
- `radius_index` → Radius = `RING_FIRST_RADIUS + index * RING_SPACING` (config.gd)
- `speed` in rad/s, `direction` 1 / -1; benachbarte Ringe muessen gegenlaeufig drehen
  (sonst Warnung im Log).
- `glasses`: Glastyp-IDs aus `Config.GLASS_TYPES`, `""` = leerer Platz. Plaetze werden
  gleichmaessig auf den Ring verteilt.
- Fehlt ein Level, laedt `LevelLoader` das hoechste vorhandene darunter (Warnung).
- Beim ersten Android/iOS-Export pruefen, dass `levels/*.json` im Paket landen
  (sonst `*.json` im Export-Filter ergaenzen).

## Spielablauf (Code-Aufteilung)
- `game.gd` – Eingabe, Tropfen-Bewegung + Kollision (Swept-Circle gegen Glaeser), Effekte, Levelende
- `ring_field.gd` – alle Ringe, Druck nach innen, Gefahrenlinie, Treffer/Platzen/Sieg-Signale
- `glass_ring.gd`, `glass.gd` – Ring bzw. einzelnes Glas (Fuellstand, Badge, Wackeln, Platzen)
- `GameState`: `start_run()` (Menue), `begin_level()` (Szenenstart), `retry_level()`, `next_level()`

## Konventionen
- Szenenwechsel nur ueber `Transition.go_to(Config.SCENE_...)`.
- Node-Namen deutsch wie im Spiel (Hut, Flasche, Boden, Ziellinie ...), Code/Bezeichner englisch oder deutsch – im jeweiligen Skript einheitlich.
- Der Untergrund ist die Node `World/Boden` in `game.tscn` und austauschbar;
  kein anderes Skript darf auf ihn zugreifen.
- Die Flasche dreht um die Hutmitte: `FlaschePivot` liegt in der Hutmitte,
  der SVG-Ursprung der Flasche liegt im Pivot (Sprite-Offset).
- Stil: Comic, Draufsicht, dicke schwarze Konturen (`COLOR_OUTLINE`), flache Farben,
  harte Schlagschatten. Gezeichnete Elemente (`_draw`) folgen demselben Stil.
- Einrueckung mit Tabs (Godot-Standard), statische Typen wo moeglich.
- `.godot/` und `export_presets.cfg` nicht committen; `*.uid`- und `*.import`-Dateien schon.

## Stand
- Schritt 1: Hauptmenue, Platzhalter-Screens, Spielszene-Prototyp (Zielen, Schuss, HUD).
- Schritt 2: Glaeser, Ringe (JSON), Trefferlogik, Druck & Herzen, Sieg-/Game-Over-Screen.
- Schrift: „Bangers“ (Google Fonts, SIL OFL, `ui/fonts/OFL.txt`), eingebunden ueber
  `ui/comic_font.tres` (FontVariation) und das Projekt-Theme. Neue Texte immer ueber
  diese Resource, keine SystemFont.
- Fuer spaeter vorhanden, noch nicht benutzt: `assets/hut_bombe|eis|party|gold.svg`.
