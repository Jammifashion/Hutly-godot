@tool
class_name Hearts
extends Control
## Lebensanzeige: volle und leere Comic-Herzen, rechtsbuendig.

@export var max_hearts := Config.START_LIVES:
	set(v):
		max_hearts = v
		queue_redraw()
@export var filled := Config.START_LIVES:
	set(v):
		filled = v
		queue_redraw()

var _shape := _build_heart()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


static func _build_heart() -> PackedVector2Array:
	# Klassische Herzkurve, normiert auf ca. -1..1
	var pts := PackedVector2Array()
	var steps := 48
	for i in steps:
		var t := TAU * i / steps
		var x := 16.0 * pow(sin(t), 3)
		var y := -(13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t))
		pts.append(Vector2(x, y + 2.0) / 17.0)
	return pts


func _draw() -> void:
	var s := Config.HEART_SIZE
	var total := max_hearts * s + (max_hearts - 1) * Config.HEART_GAP
	var x := size.x - total + s * 0.5
	var cy := size.y * 0.5
	for i in max_hearts:
		var center := Vector2(x + i * (s + Config.HEART_GAP), cy)
		var pts := PackedVector2Array()
		for p in _shape:
			pts.append(center + p * s * 0.5)
		var shadow := PackedVector2Array()
		for p in pts:
			shadow.append(p + Config.HARD_SHADOW_OFFSET * 0.5)
		draw_colored_polygon(shadow, Config.COLOR_OUTLINE)
		var full := i < filled
		draw_colored_polygon(pts, Config.COLOR_RED if full else Config.COLOR_WHITE.darkened(0.25))
		if full:
			draw_circle(center + Vector2(-s * 0.2, -s * 0.18), s * 0.09, Config.COLOR_WHITE)
		pts.append(pts[0])
		draw_polyline(pts, Config.COLOR_OUTLINE, 6.0, true)
