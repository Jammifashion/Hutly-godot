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
- `assets/` – Comic-SVGs, importiert mit `svg/scale=2.0` (+ Mipmaps).
  Sprite-Skalierung daher immer `gewuenschte_px / (svg_masse * Config.SVG_IMPORT_SCALE)`.

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
- Schritt 2 (offen): Glaeser, Ringe, Punkte-Logik.
- Schrift ist aktuell eine SystemFont (Arial Black / Impact / Fallback). Fuer Mobilgeraete
  spaeter eine eigene Comic-Schrift (TTF/OTF) in `ui/` einbinden.
