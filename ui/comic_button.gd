@tool
class_name ComicButton
extends BaseButton
## Pill-Button im Comic-Stil: dicke schwarze Kontur, harter Schlagschatten,
## drueckt sich beim Antippen kurz in den Schatten ein.

const FONT := preload("res://ui/comic_font.tres")

@export var text := "BUTTON":
	set(value):
		text = value
		queue_redraw()
@export var fill_color := Config.COLOR_WHITE:
	set(value):
		fill_color = value
		queue_redraw()
@export var text_color := Config.COLOR_OUTLINE:
	set(value):
		text_color = value
		queue_redraw()
@export var font_size := Config.MENU_BUTTON_FONT_SIZE:
	set(value):
		font_size = value
		queue_redraw()

var _press := 0.0 # 0 = oben, 1 = ganz eingedrueckt
var _tween: Tween


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)


func _on_button_down() -> void:
	_animate_to(1.0, Config.BUTTON_PRESS_IN_TIME)


func _on_button_up() -> void:
	# Auch bei ganz kurzem Tippen sichtbar eindruecken, dann zurueckfedern.
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if _press < 1.0:
		_tween.tween_method(_set_press, _press, 1.0, Config.BUTTON_PRESS_IN_TIME)
	_tween.tween_method(_set_press, 1.0, 0.0, Config.BUTTON_RELEASE_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_to(target: float, time: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_set_press, _press, target, time)


func _set_press(value: float) -> void:
	_press = value
	queue_redraw()


func _draw() -> void:
	var radius := int(size.y * 0.5)
	var shadow_offset := Config.BUTTON_SHADOW_OFFSET
	var push := shadow_offset * clampf(_press, 0.0, 1.2)

	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Config.COLOR_OUTLINE
	shadow.set_corner_radius_all(radius)
	draw_style_box(shadow, Rect2(shadow_offset, size))

	var body := StyleBoxFlat.new()
	body.bg_color = fill_color.darkened(0.12) if _press > 0.5 else fill_color
	body.border_color = Config.COLOR_OUTLINE
	body.set_border_width_all(Config.BUTTON_BORDER)
	body.set_corner_radius_all(radius)
	draw_style_box(body, Rect2(push, size))

	var ascent := FONT.get_ascent(font_size)
	var descent := FONT.get_descent(font_size)
	var baseline := push + Vector2(0, (size.y + ascent - descent) * 0.5)
	draw_string(FONT, baseline, text, HORIZONTAL_ALIGNMENT_CENTER, size.x,
		font_size, text_color)
