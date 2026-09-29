class_name Hud
extends Control
## Obere Leiste im Spiel: LEVEL links, Punkte-Pill mittig, Herzen rechts.

@onready var level_label: Label = $LevelLabel
@onready var score_pill: ScorePill = $ScorePill
@onready var hearts: Hearts = $Herzen

var _edge_flash: EdgeFlash
var _bump_tween: Tween


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

	_edge_flash = EdgeFlash.new()
	add_child(_edge_flash)

	get_viewport().size_changed.connect(_layout)
	_layout()


## Laesst Punkte von screen_pos zur Punkteanzeige fliegen und zaehlt sie dort.
func fly_points(screen_pos: Vector2, points: int) -> void:
	var f := FlyingScore.new()
	f.setup(screen_pos, score_pill.position + score_pill.size * 0.5, points)
	f.arrived.connect(_on_points_arrived)
	add_child(f)


func flash_edge() -> void:
	_edge_flash.flash()


func _on_points_arrived(points: int) -> void:
	GameState.score += points
	if _bump_tween:
		_bump_tween.kill()
	score_pill.scale = Vector2.ONE * Config.SCORE_BUMP_SCALE
	_bump_tween = create_tween()
	_bump_tween.tween_property(score_pill, "scale", Vector2.ONE, Config.SCORE_BUMP_TIME) 		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
	score_pill.pivot_offset = Config.SCORE_PILL_SIZE * 0.5
	score_pill.position = Vector2((vs.x - Config.SCORE_PILL_SIZE.x) * 0.5,
		top + (h - Config.SCORE_PILL_SIZE.y) * 0.5)
	hearts.position = Vector2(vs.x * 0.65, top)
	hearts.size = Vector2(vs.x * 0.35 - side, h)
