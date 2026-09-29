class_name ComicDrop
extends Node2D
## Comic-Tropfen: fliegt geradeaus entlang seiner Rotation (+x).

var direction := Vector2.RIGHT
var _age := 0.0
var _shape := PackedVector2Array()


func setup(start: Vector2, dir: Vector2) -> void:
	position = start
	direction = dir.normalized()
	rotation = direction.angle()
	scale = Vector2.ZERO


func _ready() -> void:
	# Runde Front bei +x, Spitze zeigt nach hinten (-x).
	var r := Config.DROP_RADIUS
	var d := r * Config.DROP_TAIL
	var phi := acos(r / d)
	var steps := 20
	for i in steps + 1:
		var a := lerpf(-(PI - phi), PI - phi, float(i) / steps)
		_shape.append(Vector2.from_angle(a) * r)
	_shape.append(Vector2(-d, 0))


func _process(delta: float) -> void:
	_age += delta
	position += direction * Config.DROP_SPEED * delta
	var pop := minf(1.0, _age / Config.DROP_POP_TIME)
	var wob := sin(_age * Config.DROP_WOBBLE_SPEED) * Config.DROP_WOBBLE
	scale = Vector2(1.0 + wob, 1.0 - wob) * pop
	if _age > Config.DROP_LIFETIME or _is_off_screen():
		queue_free()


func _is_off_screen() -> bool:
	var vs := get_viewport_rect().size
	var m := Config.DROP_RADIUS * Config.DROP_TAIL * 2.0
	return position.x < -m or position.y < -m or position.x > vs.x + m or position.y > vs.y + m


func _draw() -> void:
	var r := Config.DROP_RADIUS
	draw_colored_polygon(_shape, Config.COLOR_DROP)
	draw_circle(Vector2(-r * 0.15, r * 0.35), r * 0.45, Config.COLOR_DROP_SHADE)
	var outline := _shape.duplicate()
	outline.append(_shape[0])
	draw_polyline(outline, Config.COLOR_OUTLINE, 5.0, true)
	draw_circle(Vector2(r * 0.25, -r * 0.35), r * 0.22, Config.COLOR_WHITE)
