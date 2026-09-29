extends Control
## Obere Leiste im Spiel: LEVEL links, Punkte-Pill mittig, Herzen rechts.

@onready var level_label: Label = $LevelLabel
@onready var score_pill: ScorePill = $ScorePill
@onready var hearts: Hearts = $Herzen


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	level_label.add_theme_font_size_override("font_size", Config.LEVEL_FONT_SIZE)
	level_label.add_theme_color_override("font_color", Config.COLOR_WHITE)
	level_label.add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	level_label.add_theme_constant_override("outline_size", Config.LEVEL_OUTLINE)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	GameState.score_changed.connect(func(v: int) -> void: score_pill.value = v)
	GameState.level_changed.connect(_set_level)
	GameState.lives_changed.connect(func(v: int) -> void: hearts.filled = v)
	score_pill.value = GameState.score
	hearts.max_hearts = Config.START_LIVES
	hearts.filled = GameState.lives
	_set_level(GameState.level)

	get_viewport().size_changed.connect(_layout)
	_layout()


func _set_level(v: int) -> void:
	level_label.text = "LEVEL %d" % v


func _layout() -> void:
	var vs := get_viewport_rect().size
	var top := Config.HUD_TOP_MARGIN
	var side := Config.HUD_SIDE_MARGIN
	var h := Config.HUD_HEIGHT
	level_label.position = Vector2(side, top)
	level_label.size = Vector2(vs.x * 0.35, h)
	score_pill.size = Config.SCORE_PILL_SIZE
	score_pill.position = Vector2((vs.x - Config.SCORE_PILL_SIZE.x) * 0.5,
		top + (h - Config.SCORE_PILL_SIZE.y) * 0.5)
	hearts.position = Vector2(vs.x * 0.65, top)
	hearts.size = Vector2(vs.x * 0.35 - side, h)
