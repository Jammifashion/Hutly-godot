@tool
extends Node2D
## Blauer Hintergrund mit langsam rotierenden Sonnenstrahlen.

@export var ray_count := Config.MENU_RAY_COUNT
@export var radius := Config.MENU_RAY_RADIUS
@export var base_color := Config.COLOR_SKY
@export var ray_color := Config.COLOR_SKY_RAY
@export var speed := Config.MENU_RAY_SPEED


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	rotation = wrapf(rotation + speed * delta, 0.0, TAU)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, base_color)
	var step := TAU / ray_count
	for i in ray_count:
		var a := i * step
		draw_colored_polygon(PackedVector2Array([
			Vector2.ZERO,
			Vector2.from_angle(a) * radius,
			Vector2.from_angle(a + step * 0.5) * radius,
		]), ray_color)
