class_name SpeechBubble
extends Node2D
## Comic-Sprechblase ("PROST!", "SCHLUCK!"): ploppt auf, steigt, verblasst.
## position = Punkt, auf den der Zipfel zeigt.

const FONT := preload("res://ui/comic_font.tres")

var _text := ""
var _text_color := Config.COLOR_OUTLINE
var _box_size := Vector2.ZERO
var _box_offset := Vector2.ZERO # Mitte der Blase relativ zum Zipfel


func setup(at: Vector2, text: String, text_color: Color) -> void:
	position = at
	_text = text
	_text_color = text_color
	var fs := Config.BUBBLE_FONT_SIZE
	_box_size = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs) + Config.BUBBLE_PADDING * 2.0
	_box_offset = Config.BUBBLE_OFFSET
	rotation = deg_to_rad(randf_range(-Config.BUBBLE_TILT_DEG, Config.BUBBLE_TILT_DEG))
	scale = Vector2.ZERO


func _ready() -> void:
	# Blase im Bild halten (Zipfel darf schraeg zeigen).
	var vs := get_viewport_rect().size
	var half := _box_size.x * 0.5 + 20.0
	var cx := clampf(position.x + _box_offset.x, half, vs.x - half)
	_box_offset.x = cx - position.x

	var t := create_tween()
	t.tween_property(self, "scale", Vector2.ONE, Config.BUBBLE_IN_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(self, "position:y", position.y - 30.0, Config.BUBBLE_HOLD_TIME)
	t.tween_property(self, "modulate:a", 0.0, Config.BUBBLE_OUT_TIME)
	t.tween_callback(queue_free)


func _draw() -> void:
	var rect := Rect2(_box_offset - _box_size * 0.5, _box_size)
	var tail_base := Vector2(_box_offset.x * 0.5, rect.end.y - Config.BUBBLE_BORDER)
	var tail := PackedVector2Array([
		tail_base + Vector2(-Config.BUBBLE_TAIL * 0.5, 0),
		tail_base + Vector2(Config.BUBBLE_TAIL * 0.5, 0),
		Vector2(0, -8),
	])

	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Config.COLOR_OUTLINE
	shadow.set_corner_radius_all(int(_box_size.y * 0.5))
	draw_style_box(shadow, Rect2(rect.position + Config.HARD_SHADOW_OFFSET * 0.6, rect.size))

	draw_colored_polygon(tail, Config.COLOR_WHITE)
	var outline := tail.duplicate()
	outline.append(tail[0])
	draw_polyline(outline, Config.COLOR_OUTLINE, Config.BUBBLE_BORDER, true)

	var box := StyleBoxFlat.new()
	box.bg_color = Config.COLOR_WHITE
	box.border_color = Config.COLOR_OUTLINE
	box.set_border_width_all(Config.BUBBLE_BORDER)
	box.set_corner_radius_all(int(_box_size.y * 0.5))
	draw_style_box(box, rect)

	var fs := Config.BUBBLE_FONT_SIZE
	var baseline := Vector2(rect.position.x, rect.get_center().y + (FONT.get_ascent(fs) - FONT.get_descent(fs)) * 0.5)
	draw_string(FONT, baseline, _text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, fs, _text_color)
