class_name EdgeFlash
extends Control
## Roter Blitz am Bildschirmrand (bei Herzverlust).

const STEPS := 10

var _alpha := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func flash() -> void:
	var t := create_tween()
	t.tween_method(_set_alpha, 1.0, 0.0, Config.EDGE_FLASH_TIME) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _set_alpha(v: float) -> void:
	_alpha = v
	queue_redraw()


func _draw() -> void:
	if _alpha <= 0.0:
		return
	var sw := Config.EDGE_FLASH_WIDTH / STEPS
	for i in STEPS:
		var c := Config.COLOR_FLASH
		c.a = _alpha * Config.EDGE_FLASH_ALPHA * (1.0 - float(i) / STEPS)
		var inset := i * sw
		draw_rect(Rect2(inset, inset, size.x - inset * 2.0, sw), c)
		draw_rect(Rect2(inset, size.y - inset - sw, size.x - inset * 2.0, sw), c)
		draw_rect(Rect2(inset, inset + sw, sw, size.y - (inset + sw) * 2.0), c)
		draw_rect(Rect2(size.x - inset - sw, inset + sw, sw, size.y - (inset + sw) * 2.0), c)
