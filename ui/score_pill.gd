@tool
class_name ScorePill
extends Control
## Weisse Pill mit Punktestand.

const FONT := preload("res://ui/comic_font.tres")

@export var value := 0:
	set(v):
		value = v
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var radius := int(size.y * 0.5)
	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Config.COLOR_OUTLINE
	shadow.set_corner_radius_all(radius)
	draw_style_box(shadow, Rect2(Config.HARD_SHADOW_OFFSET * 0.7, size))

	var body := StyleBoxFlat.new()
	body.bg_color = Config.COLOR_WHITE
	body.border_color = Config.COLOR_OUTLINE
	body.set_border_width_all(Config.BUTTON_BORDER)
	body.set_corner_radius_all(radius)
	draw_style_box(body, Rect2(Vector2.ZERO, size))

	var fs := Config.SCORE_FONT_SIZE
	var baseline := Vector2(0, (size.y + FONT.get_ascent(fs) - FONT.get_descent(fs)) * 0.5)
	draw_string(FONT, baseline, str(value), HORIZONTAL_ALIGNMENT_CENTER, size.x,
		fs, Config.COLOR_OUTLINE)
