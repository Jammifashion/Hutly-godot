class_name Splash
extends Node2D
## Kleine Comic-Spritzer, die auseinanderfliegen und schrumpfen.

var _color := Color.WHITE
var _pos := PackedVector2Array()
var _vel := PackedVector2Array()
var _size := PackedFloat32Array()
var _age := 0.0


func setup(at: Vector2, color: Color, count: int, speed: float) -> void:
	position = at
	_color = color
	for i in count:
		var dir := Vector2.from_angle(randf() * TAU)
		_pos.append(Vector2.ZERO)
		_vel.append(dir * speed * randf_range(0.5, 1.0))
		_size.append(Config.SPLASH_RADIUS * randf_range(0.6, 1.2))


func _process(delta: float) -> void:
	_age += delta
	if _age >= Config.SPLASH_LIFETIME:
		queue_free()
		return
	for i in _pos.size():
		_pos[i] += _vel[i] * delta
		_vel[i] *= 0.9
	queue_redraw()


func _draw() -> void:
	var k := 1.0 - _age / Config.SPLASH_LIFETIME
	for i in _pos.size():
		var r := _size[i] * k
		draw_circle(_pos[i], r + 3.0, Config.COLOR_OUTLINE)
		draw_circle(_pos[i], r, _color)
