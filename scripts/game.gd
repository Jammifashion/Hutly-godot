extends Node2D
## Spielszene (Prototyp): Zielen mit dem Finger, Schuss beim Loslassen.


@onready var world: Node2D = $World
@onready var hut: Sprite2D = $World/Hut
@onready var danger_ring: DangerRing = $World/GefahrenRing
@onready var aim_line: AimLine = $World/Ziellinie
@onready var drops: Node2D = $World/Tropfen
@onready var flasche_pivot: Node2D = $World/FlaschePivot
@onready var flasche: Sprite2D = $World/FlaschePivot/Flasche

var _center := Vector2.ZERO
var _neck_distance := 0.0
var _flasche_scale := 1.0
var _aim_touch := -1
var _aim_angle := Config.AIM_START_ANGLE
var _cooldown := 0.0
var _shake := 0.0
var _recoil_tween: Tween


func _ready() -> void:
	GameState.start_run()
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
	if _shake > 0.0:
		_shake = maxf(0.0, _shake - delta)
		var strength := Config.SHAKE_STRENGTH * _shake / Config.SHAKE_DURATION
		world.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength
	else:
		world.position = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()
		return
	if Transition.is_busy():
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
