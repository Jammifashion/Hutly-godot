extends Node2D
## Spielszene: Zielen, Schiessen, Glaeser fuellen, Druck der Ringe, Sieg / Game Over.

@onready var world: Node2D = $World
@onready var hut: Sprite2D = $World/Hut
@onready var danger_ring: DangerRing = $World/GefahrenRing
@onready var ring_field: RingField = $World/Ringe
@onready var aim_line: AimLine = $World/Ziellinie
@onready var drops: Node2D = $World/Tropfen
@onready var flasche_pivot: Node2D = $World/FlaschePivot
@onready var flasche: Sprite2D = $World/FlaschePivot/Flasche
@onready var effects: Node2D = $World/Effekte
@onready var hud_layer: CanvasLayer = $HUD
@onready var hud: Hud = $HUD/Hud

var _center := Vector2.ZERO
var _neck_distance := 0.0
var _flasche_scale := 1.0
var _aim_touch := -1
var _aim_angle := Config.AIM_START_ANGLE
var _cooldown := 0.0
var _shake := 0.0
var _recoil_tween: Tween
var _ended := false


func _ready() -> void:
	GameState.begin_level()
	ring_field.build(LevelLoader.load_level(GameState.level))
	ring_field.glass_popped.connect(_on_glass_popped)
	ring_field.danger_touched.connect(_on_danger_touched)
	ring_field.cleared.connect(_on_cleared)
	get_viewport().size_changed.connect(_layout)
	_layout()
	_set_aim_angle(_aim_angle)


func _layout() -> void:
	var vs := get_viewport_rect().size
	var hut_diameter := vs.x * Config.HUT_DIAMETER_RATIO
	_center = Vector2(vs.x * 0.5, vs.y * Config.HUT_CENTER_Y_RATIO)

	hut.position = _center
	hut.scale = Vector2.ONE * hut_diameter / (Config.HUT_SVG_DIAMETER * Config.SVG_IMPORT_SCALE)

	danger_ring.position = _center
	danger_ring.radius = vs.x * Config.DANGER_RING_DIAMETER_RATIO * 0.5
	ring_field.position = _center
	ring_field.danger_radius = danger_ring.radius

	# Flasche: SVG-Ursprung liegt genau im Drehpunkt (= Hutmitte).
	var svg_scale := hut_diameter * Config.FLASCHE_LENGTH_RATIO / Config.FLASCHE_SVG_LENGTH
	_flasche_scale = svg_scale / Config.SVG_IMPORT_SCALE
	_neck_distance = Config.FLASCHE_SVG_NECK_X * svg_scale
	flasche_pivot.position = _center
	flasche.offset = -Config.FLASCHE_SVG_CENTER * Config.SVG_IMPORT_SCALE
	flasche.scale = Vector2.ONE * _flasche_scale

	aim_line.position = _center
	aim_line.start_distance = _neck_distance + Config.AIM_LINE_GAP_TO_NECK


func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	_update_drops(delta)
	if _shake > 0.0:
		_shake = maxf(0.0, _shake - delta)
		var strength := Config.SHAKE_STRENGTH * _shake / Config.SHAKE_DURATION
		world.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength
	else:
		world.position = Vector2.ZERO


# --- Eingabe --------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()
		return
	if Transition.is_busy() or _ended:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _aim_touch == -1:
			_aim_touch = touch.index
			_aim_at(touch.position)
			aim_line.visible = true
		elif not touch.pressed and touch.index == _aim_touch:
			_aim_at(touch.position)
			_aim_touch = -1
			aim_line.visible = false
			_try_shoot()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _aim_touch:
			_aim_at(drag.position)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_back_to_menu()


func _back_to_menu() -> void:
	Transition.go_to(Config.SCENE_MENU)


func _aim_at(screen_pos: Vector2) -> void:
	var d := screen_pos - world.position - _center
	if d.length() < Config.AIM_MIN_DISTANCE:
		return
	_set_aim_angle(d.angle())


func _set_aim_angle(angle: float) -> void:
	_aim_angle = angle
	flasche_pivot.rotation = angle
	aim_line.rotation = angle


# --- Schuss & Treffer -----------------------------------------------------

func _try_shoot() -> void:
	if _cooldown > 0.0:
		return
	_cooldown = Config.SHOT_COOLDOWN
	var dir := Vector2.from_angle(_aim_angle)
	var drop := ComicDrop.new()
	drop.setup(_center + dir * _neck_distance, dir)
	drops.add_child(drop)
	_recoil()
	_shake = Config.SHAKE_DURATION


func _update_drops(delta: float) -> void:
	for node in drops.get_children():
		var drop := node as ComicDrop
		if drop.is_queued_for_deletion():
			continue
		var from := drop.position
		var to := from + drop.velocity * delta
		var hit := ring_field.find_first_hit(from - ring_field.position, to - ring_field.position,
			Config.DROP_RADIUS)
		if hit.is_empty():
			drop.position = to
			continue
		var glass: Glass = hit["glass"]
		_spawn_splash(ring_field.position + hit["point"], glass.color,
			Config.SPLASH_COUNT, Config.SPLASH_SPEED)
		drop.queue_free()
		ring_field.apply_hit(glass)


func _on_glass_popped(glass: Glass, local_pos: Vector2) -> void:
	var pos := ring_field.position + local_pos
	_spawn_splash(pos, glass.color, Config.POP_SPLASH_COUNT, Config.POP_SPLASH_SPEED)
	_spawn_bubble(pos, Config.BUBBLE_TEXT_PROST, Config.COLOR_SKY)
	hud.fly_points(world.position + pos, glass.points)


func _on_danger_touched(_glass: Glass, local_pos: Vector2) -> void:
	if _ended:
		return
	GameState.lives = maxi(0, GameState.lives - 1)
	_spawn_bubble(ring_field.position + local_pos, Config.BUBBLE_TEXT_SCHLUCK, Config.COLOR_RED)
	hud.flash_edge()
	_shake = Config.SHAKE_DURATION * 2.0
	if GameState.lives <= 0:
		_end_level(false)


func _on_cleared() -> void:
	_end_level(true)


func _spawn_splash(at: Vector2, color: Color, count: int, speed: float) -> void:
	var s := Splash.new()
	s.setup(at, color, count, speed)
	effects.add_child(s)


func _spawn_bubble(at: Vector2, text: String, color: Color) -> void:
	var b := SpeechBubble.new()
	b.setup(at, text, color)
	effects.add_child(b)


func _recoil() -> void:
	# Squash & Stretch entlang der Flaschenachse (lokal +x = Schussrichtung).
	if _recoil_tween:
		_recoil_tween.kill()
	var base := Vector2.ONE * _flasche_scale
	_recoil_tween = create_tween().set_parallel(true)
	_recoil_tween.tween_property(flasche, "position", Vector2(-Config.RECOIL_DISTANCE, 0), Config.RECOIL_IN_TIME)
	_recoil_tween.tween_property(flasche, "scale", base * Config.RECOIL_SQUASH, Config.RECOIL_IN_TIME)
	_recoil_tween.chain().tween_property(flasche, "position", Vector2.ZERO, Config.RECOIL_OUT_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_recoil_tween.tween_property(flasche, "scale", base, Config.RECOIL_OUT_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


# --- Levelende ------------------------------------------------------------

func _end_level(win: bool) -> void:
	if _ended:
		return
	_ended = true
	_aim_touch = -1
	aim_line.visible = false
	ring_field.active = false
	await get_tree().create_timer(Config.RESULT_DELAY_WIN if win else Config.RESULT_DELAY_LOSE).timeout

	var panel := ResultPanel.new()
	panel.setup(win, GameState.score, GameState.lives)
	if win:
		panel.primary_pressed.connect(func() -> void:
			GameState.next_level()
			Transition.go_to(Config.SCENE_GAME))
	else:
		panel.primary_pressed.connect(func() -> void:
			GameState.retry_level()
			Transition.go_to(Config.SCENE_GAME))
	panel.menu_pressed.connect(_back_to_menu)
	hud_layer.add_child(panel)
