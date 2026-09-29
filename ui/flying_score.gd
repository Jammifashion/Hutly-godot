class_name FlyingScore
extends Label
## Punktzahl, die im Bogen zur Punkteanzeige fliegt und dort "arrived" meldet.

signal arrived(points: int)

var _points := 0
var _from := Vector2.ZERO
var _to := Vector2.ZERO


func setup(from: Vector2, to: Vector2, points: int) -> void:
	_points = points
	_from = from
	_to = to
	text = "+%d" % points
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_font_size_override("font_size", Config.FLY_SCORE_FONT_SIZE)
	add_theme_color_override("font_color", Config.COLOR_YELLOW)
	add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	add_theme_constant_override("outline_size", Config.FLY_SCORE_OUTLINE)


func _ready() -> void:
	reset_size()
	pivot_offset = size * 0.5
	_move(0.0)
	var t := create_tween()
	t.tween_method(_move, 0.0, 1.0, Config.FLY_SCORE_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.tween_callback(func() -> void:
		arrived.emit(_points)
		queue_free())


func _move(t: float) -> void:
	# Quadratische Bezier-Kurve mit Bogen nach oben.
	var ctrl := (_from + _to) * 0.5 + Vector2(0, -Config.FLY_SCORE_ARC)
	var p := _from.lerp(ctrl, t).lerp(ctrl.lerp(_to, t), t)
	position = p - size * 0.5
	scale = Vector2.ONE * lerpf(1.3, 0.7, t)
