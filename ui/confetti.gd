class_name Confetti
extends Node2D
## Konfetti, das von oben ueber den ganzen Bildschirm faellt.

var _pos := PackedVector2Array()
var _speed := PackedFloat32Array()
var _rot := PackedFloat32Array()
var _spin := PackedFloat32Array()
var _phase := PackedFloat32Array()
var _color: Array[Color] = []
var _time := 0.0


func _ready() -> void:
	var vs := get_viewport_rect().size
	for i in Config.CONFETTI_COUNT:
		_pos.append(Vector2(randf() * vs.x, -randf() * vs.y * 0.8 - Config.CONFETTI_SIZE.x))
		_speed.append(randf_range(Config.CONFETTI_FALL_SPEED.x, Config.CONFETTI_FALL_SPEED.y))
		_rot.append(randf() * TAU)
		_spin.append(randf_range(-8.0, 8.0))
		_phase.append(randf() * TAU)
		_color.append(Config.CONFETTI_COLORS.pick_random())


func _process(delta: float) -> void:
	_time += delta
	var vs := get_viewport_rect().size
	var any_visible := false
	for i in _pos.size():
		_pos[i].y += _speed[i] * delta
		_pos[i].x += cos(_time * 3.0 + _phase[i]) * Config.CONFETTI_SWAY * delta
		_rot[i] += _spin[i] * delta
		if _pos[i].y < vs.y + Config.CONFETTI_SIZE.x:
			any_visible = true
	if not any_visible:
		queue_free()
	queue_redraw()


func _draw() -> void:
	var s := Config.CONFETTI_SIZE
	for i in _pos.size():
		draw_set_transform(_pos[i], _rot[i], Vector2(1.0, absf(cos(_time * 5.0 + _phase[i]))))
		draw_rect(Rect2(-s * 0.5, s), _color[i])
	draw_set_transform(Vector2.ZERO)
