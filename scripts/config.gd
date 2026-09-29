class_name Config
extends RefCounted
## Alle Groessen, Farben und Spielwerte an einem Ort.
## Pixelwerte beziehen sich auf die Design-Aufloesung 1080 x 1920
## (Stretch canvas_items / keep_width: Breite ist immer 1080).

# --- Szenen ---------------------------------------------------------------
const SCENE_MENU := "res://scenes/menu.tscn"
const SCENE_GAME := "res://scenes/game.tscn"
const SCENE_HUTREGAL := "res://scenes/hutregal.tscn"
const SCENE_SETTINGS := "res://scenes/settings.tscn"

# --- Farben ---------------------------------------------------------------
const COLOR_OUTLINE := Color("1b1b1b")
const COLOR_SKY := Color("2F7CF6")
const COLOR_SKY_RAY := Color("4A93FF")
const COLOR_YELLOW := Color("F5C518")
const COLOR_WHITE := Color("FFFFFF")
const COLOR_RED := Color("E8322A")
const COLOR_RED_DARK := Color("A31611")
const COLOR_DROP := Color("7FD3FF")
const COLOR_DROP_SHADE := Color("3FA8E8")

# --- SVG-Masse (in SVG-Einheiten, Import mit svg/scale = 2) ---------------
const SVG_IMPORT_SCALE := 2.0
const HUT_SVG_DIAMETER := 480.0            # Krempe ohne Schlagschatten
const FLASCHE_SVG_LENGTH := 282.0          # Flaschenboden bis Deckel
const FLASCHE_SVG_CENTER := Vector2(10, 2) # Mitte der viewBox
const FLASCHE_SVG_NECK_X := 150.0          # Spitze des Flaschenhalses

# --- Allgemeine Kontur / Schatten -----------------------------------------
const OUTLINE_WIDTH := 8.0
const HARD_SHADOW_OFFSET := Vector2(0, 12)

# --- Buttons --------------------------------------------------------------
const BUTTON_BORDER := 8
const BUTTON_SHADOW_OFFSET := Vector2(0, 12)
const BUTTON_PRESS_IN_TIME := 0.05
const BUTTON_RELEASE_TIME := 0.18

# --- Hauptmenue -----------------------------------------------------------
const MENU_RAY_COUNT := 18
const MENU_RAY_RADIUS := 2600.0
const MENU_RAY_SPEED := 0.12               # rad/s
const MENU_TITLE_TEXT := "HUT IST\nGUT!"
const MENU_TITLE_FONT_SIZE := 150
const MENU_TITLE_OUTLINE := 40
const MENU_TITLE_SHADOW := Vector2(0, 16)
const MENU_TITLE_HEIGHT := 400.0
const MENU_TITLE_Y_RATIO := 0.15           # Mitte des Titels
const MENU_TITLE_TILT_DEG := -6.0
const MENU_TITLE_WOBBLE_DEG := 2.5
const MENU_TITLE_WOBBLE_SPEED := 2.2       # rad/s
const MENU_TITLE_BOB := 10.0               # px auf und ab
const MENU_HUT_DIAMETER_RATIO := 0.52      # Anteil der Bildschirmbreite
const MENU_HUT_Y_RATIO := 0.43
const MENU_FLASCHE_LENGTH_RATIO := 0.95    # Anteil des Hut-Durchmessers
const MENU_FLASCHE_SPIN_SPEED := 0.6       # rad/s
const MENU_BUTTONS_Y_RATIO := 0.64         # Oberkante der Button-Spalte
const MENU_BUTTON_GAP := 44
const MENU_PLAY_SIZE := Vector2(640, 170)
const MENU_PLAY_FONT_SIZE := 80
const MENU_BUTTON_SIZE := Vector2(560, 120)
const MENU_BUTTON_FONT_SIZE := 50

# --- Platzhalter-Screens --------------------------------------------------
const PLACEHOLDER_TITLE_FONT_SIZE := 90
const PLACEHOLDER_TEXT_FONT_SIZE := 50
const PLACEHOLDER_BACK_SIZE := Vector2(480, 120)

# --- Spielfeld ------------------------------------------------------------
const HUT_DIAMETER_RATIO := 0.25           # Anteil der Bildschirmbreite
const HUT_CENTER_Y_RATIO := 0.45           # etwas ueber der Mitte
const DANGER_RING_DIAMETER_RATIO := 0.40
const DANGER_RING_DASH := 30.0
const DANGER_RING_GAP := 20.0
const DANGER_RING_WIDTH := 9.0
const DANGER_RING_SPEED := 0.15            # rad/s
const FLASCHE_LENGTH_RATIO := 0.95         # Anteil des Hut-Durchmessers

# --- Zielen ---------------------------------------------------------------
const AIM_START_ANGLE := -PI / 2.0         # Flasche zeigt anfangs nach oben
const AIM_MIN_DISTANCE := 30.0             # Finger naeher an Hutmitte: ignorieren
const AIM_LINE_GAP_TO_NECK := 24.0
const AIM_LINE_LENGTH := 620.0
const AIM_DASH := 34.0
const AIM_DASH_GAP := 22.0
const AIM_LINE_WIDTH := 10.0
const AIM_DASH_SPEED := 120.0              # px/s, "Ameisenlauf"
const AIM_END_RADIUS := 16.0

# --- Schuss ---------------------------------------------------------------
const SHOT_COOLDOWN := 0.25                # s
const DROP_SPEED := 1900.0                 # px/s
const DROP_RADIUS := 22.0
const DROP_TAIL := 2.4                     # Schwanzlaenge in Radien
const DROP_LIFETIME := 1.5                 # s
const DROP_POP_TIME := 0.06                # s
const DROP_WOBBLE := 0.08
const DROP_WOBBLE_SPEED := 30.0
const RECOIL_DISTANCE := 26.0              # px entlang Flaschenachse
const RECOIL_SQUASH := Vector2(0.78, 1.25)
const RECOIL_IN_TIME := 0.05
const RECOIL_OUT_TIME := 0.45
const SHAKE_STRENGTH := 12.0               # px
const SHAKE_DURATION := 0.15               # s

# --- Boden: Holzdielen ----------------------------------------------------
const PLANK_HEIGHT := 140.0
const PLANK_MIN_LENGTH := 420.0
const PLANK_MAX_LENGTH := 900.0
const PLANK_SEAM_WIDTH := 6.0
const PLANK_COLORS: Array[Color] = [Color("C98A4B"), Color("BF8043"), Color("D19455")]
const PLANK_SEAM_COLOR := Color("5A3517")
const PLANK_GRAIN_COLOR := Color(0.35, 0.2, 0.08, 0.22)
const PLANK_NAIL_COLOR := Color("3A2210")
const PLANK_SEED := 1337
const FLOOR_MARGIN := 60.0                 # Ueberstand fuer Screen-Shake

# --- HUD ------------------------------------------------------------------
const HUD_TOP_MARGIN := 80.0
const HUD_SIDE_MARGIN := 44.0
const HUD_HEIGHT := 100.0
const SCORE_PILL_SIZE := Vector2(300, 100)
const SCORE_FONT_SIZE := 60
const LEVEL_FONT_SIZE := 50
const LEVEL_OUTLINE := 18
const HEART_SIZE := 66.0
const HEART_GAP := 12.0

# --- Spielstand -----------------------------------------------------------
const START_LIVES := 3
const START_LEVEL := 1

# --- Szenenwechsel --------------------------------------------------------
const TRANSITION_TIME := 0.28              # s pro Haelfte
const TRANSITION_SKEW := 360.0             # px Schraege der Wischkante
const TRANSITION_EDGE := 34.0              # gelbe Kante
