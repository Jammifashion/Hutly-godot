extends Control
## Hauptmenue.

@onready var sunburst: Node2D = $Sonnenstrahlen
@onready var title: Label = $Titel
@onready var hut_gruppe: Node2D = $HutGruppe
@onready var hut: Sprite2D = $HutGruppe/Hut
@onready var flasche: Sprite2D = $HutGruppe/Flasche
@onready var buttons: VBoxContainer = $Buttons
@onready var btn_play: ComicButton = $Buttons/Spielen
@onready var btn_hutregal: ComicButton = $Buttons/Hutregal
@onready var btn_settings: ComicButton = $Buttons/Einstellungen

var _time := 0.0
var _title_y := 0.0


func _ready() -> void:
	title.text = Config.MENU_TITLE_TEXT
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", Config.MENU_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", Config.COLOR_YELLOW)
	title.add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	title.add_theme_constant_override("outline_size", Config.MENU_TITLE_OUTLINE)
	title.add_theme_color_override("font_shadow_color", Config.COLOR_OUTLINE)
	title.add_theme_constant_override("shadow_offset_x", int(Config.MENU_TITLE_SHADOW.x))
	title.add_theme_constant_override("shadow_offset_y", int(Config.MENU_TITLE_SHADOW.y))
	title.add_theme_constant_override("shadow_outline_size", Config.MENU_TITLE_OUTLINE)
	title.add_theme_constant_override("line_spacing", -int(Config.MENU_TITLE_FONT_SIZE * 0.25))

	buttons.add_theme_constant_override("separation", Config.MENU_BUTTON_GAP)
	_setup_button(btn_play, "SPIELEN", Config.COLOR_YELLOW, Config.MENU_PLAY_SIZE, Config.MENU_PLAY_FONT_SIZE)
	_setup_button(btn_hutregal, "HUTREGAL", Config.COLOR_WHITE, Config.MENU_BUTTON_SIZE, Config.MENU_BUTTON_FONT_SIZE)
	_setup_button(btn_settings, "EINSTELLUNGEN", Config.COLOR_WHITE, Config.MENU_BUTTON_SIZE, Config.MENU_BUTTON_FONT_SIZE)
	btn_play.pressed.connect(Transition.go_to.bind(Config.SCENE_GAME))
	btn_hutregal.pressed.connect(Transition.go_to.bind(Config.SCENE_HUTREGAL))
	btn_settings.pressed.connect(Transition.go_to.bind(Config.SCENE_SETTINGS))

	get_viewport().size_changed.connect(_layout)
	_layout()


func _setup_button(b: ComicButton, label: String, color: Color, min_size: Vector2, fs: int) -> void:
	b.text = label
	b.fill_color = color
	b.font_size = fs
	b.custom_minimum_size = min_size
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER


func _layout() -> void:
	var vs := get_viewport_rect().size
	var hut_center := Vector2(vs.x * 0.5, vs.y * Config.MENU_HUT_Y_RATIO)
	sunburst.position = hut_center

	title.size = Vector2(vs.x, Config.MENU_TITLE_HEIGHT)
	title.pivot_offset = title.size * 0.5
	_title_y = vs.y * Config.MENU_TITLE_Y_RATIO - Config.MENU_TITLE_HEIGHT * 0.5
	title.position = Vector2(0, _title_y)

	var hut_diameter := vs.x * Config.MENU_HUT_DIAMETER_RATIO
	hut_gruppe.position = hut_center
	hut.scale = Vector2.ONE * hut_diameter / (Config.HUT_SVG_DIAMETER * Config.SVG_IMPORT_SCALE)
	var svg_scale := hut_diameter * Config.MENU_FLASCHE_LENGTH_RATIO / Config.FLASCHE_SVG_LENGTH
	flasche.offset = -Config.FLASCHE_SVG_CENTER * Config.SVG_IMPORT_SCALE
	flasche.scale = Vector2.ONE * svg_scale / Config.SVG_IMPORT_SCALE

	buttons.position = Vector2(0, vs.y * Config.MENU_BUTTONS_Y_RATIO)
	buttons.size = Vector2(vs.x, 0)


func _process(delta: float) -> void:
	_time += delta
	var wobble := sin(_time * Config.MENU_TITLE_WOBBLE_SPEED)
	title.rotation = deg_to_rad(Config.MENU_TITLE_TILT_DEG + Config.MENU_TITLE_WOBBLE_DEG * wobble)
	title.position.y = _title_y + Config.MENU_TITLE_BOB * sin(_time * Config.MENU_TITLE_WOBBLE_SPEED * 0.5)
	flasche.rotation = wrapf(flasche.rotation + Config.MENU_FLASCHE_SPIN_SPEED * delta, 0.0, TAU)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
