class_name ResultPanel
extends Control
## Sieg- bzw. Game-Over-Screen als Overlay ueber dem Spiel.
## Sieg: Titel, 1-3 Sterne, Punkte, WEITER / MENUE (+ Konfetti)
## Niederlage: Titel, Punkte, NOCHMAL / MENUE

signal primary_pressed
signal menu_pressed

var _win := false
var _score := 0
var _stars := 0
var _star_scale: Array[float] = [0.0, 0.0, 0.0]
var _card: Control
var _stars_box: Control


func setup(win: bool, score: int, stars: int) -> void:
	_win = win
	_score = score
	_stars = clampi(stars, 0, 3)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var vs := get_viewport_rect().size

	if _win:
		add_child(Confetti.new())

	_card = Control.new()
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.draw.connect(_draw_card)
	add_child(_card)

	var pad := Config.RESULT_CARD_PADDING
	var w := Config.RESULT_CARD_WIDTH
	var y := pad
	var title := _make_label(Config.RESULT_TEXT_WIN if _win else Config.RESULT_TEXT_LOSE,
		Config.RESULT_TITLE_FONT_SIZE, Config.COLOR_YELLOW if _win else Config.COLOR_RED)
	title.position = Vector2(0, y)
	title.size = Vector2(w, Config.RESULT_TITLE_FONT_SIZE * 1.2)
	y += title.size.y + Config.RESULT_GAP

	if _win:
		_stars_box = Control.new()
		_stars_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stars_box.position = Vector2(0, y)
		_stars_box.size = Vector2(w, Config.STAR_SIZE)
		_stars_box.draw.connect(_draw_stars)
		_card.add_child(_stars_box)
		y += Config.STAR_SIZE + Config.RESULT_GAP

	var label := _make_label(Config.RESULT_TEXT_POINTS, Config.RESULT_LABEL_FONT_SIZE, Config.COLOR_OUTLINE, 0)
	label.position = Vector2(0, y)
	label.size = Vector2(w, Config.RESULT_LABEL_FONT_SIZE * 1.2)
	y += label.size.y
	var score_label := _make_label(str(_score), Config.RESULT_SCORE_FONT_SIZE, Config.COLOR_YELLOW)
	score_label.position = Vector2(0, y)
	score_label.size = Vector2(w, Config.RESULT_SCORE_FONT_SIZE * 1.2)
	y += score_label.size.y + Config.RESULT_GAP

	var primary := _make_button(Config.RESULT_TEXT_NEXT if _win else Config.RESULT_TEXT_RETRY, Config.COLOR_YELLOW)
	primary.position = Vector2((w - primary.size.x) * 0.5, y)
	primary.pressed.connect(primary_pressed.emit)
	y += primary.size.y + Config.RESULT_GAP
	var menu := _make_button(Config.RESULT_TEXT_MENU, Config.COLOR_WHITE)
	menu.position = Vector2((w - menu.size.x) * 0.5, y)
	menu.pressed.connect(menu_pressed.emit)
	y += menu.size.y + pad

	_card.size = Vector2(w, y)
	_card.position = (vs - _card.size) * 0.5
	_card.pivot_offset = _card.size * 0.5
	_card.scale = Vector2.ONE * 0.5
	modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 1.0, Config.RESULT_IN_TIME * 0.5)
	t.tween_property(_card, "scale", Vector2.ONE, Config.RESULT_IN_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _win:
		for i in _stars:
			t.tween_method(_set_star.bind(i), 0.0, 1.0, Config.STAR_POP_TIME) \
				.set_delay(Config.RESULT_IN_TIME + Config.STAR_DELAY * i) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _make_label(text: String, font_size: int, color: Color, outline := -1) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	l.add_theme_constant_override("outline_size", font_size / 5 if outline < 0 else outline)
	_card.add_child(l)
	return l


func _make_button(text: String, color: Color) -> ComicButton:
	var b := ComicButton.new()
	b.text = text
	b.fill_color = color
	b.font_size = Config.RESULT_BUTTON_FONT_SIZE
	b.size = Config.RESULT_BUTTON_SIZE
	_card.add_child(b)
	return b


func _set_star(v: float, i: int) -> void:
	_star_scale[i] = v
	_stars_box.queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Config.RESULT_DIM)


func _draw_card() -> void:
	var r := Rect2(Vector2.ZERO, _card.size)
	var shadow := StyleBoxFlat.new()
	shadow.bg_color = Config.COLOR_OUTLINE
	shadow.set_corner_radius_all(48)
	_card.draw_style_box(shadow, Rect2(Config.HARD_SHADOW_OFFSET * 1.5, r.size))
	var body := StyleBoxFlat.new()
	body.bg_color = Config.COLOR_WHITE
	body.border_color = Config.COLOR_OUTLINE
	body.set_border_width_all(Config.BUTTON_BORDER)
	body.set_corner_radius_all(48)
	_card.draw_style_box(body, r)


func _draw_stars() -> void:
	var s := Config.STAR_SIZE
	var total := 3.0 * s + 2.0 * Config.STAR_GAP
	var x0 := (_stars_box.size.x - total) * 0.5 + s * 0.5
	for i in 3:
		var center := Vector2(x0 + i * (s + Config.STAR_GAP), s * 0.5)
		# leerer Stern als Hintergrund, gefuellter ploppt darueber auf
		_draw_star(center, s * 0.5, Config.COLOR_STAR_EMPTY)
		if _star_scale[i] > 0.0:
			_draw_star(center, s * 0.5 * _star_scale[i], Config.COLOR_YELLOW)


func _draw_star(center: Vector2, r: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for k in 10:
		var rr := r if k % 2 == 0 else r * 0.48
		pts.append(center + Vector2.from_angle(-PI / 2.0 + k * PI / 5.0) * rr)
	var shadow := PackedVector2Array()
	for p in pts:
		shadow.append(p + Config.HARD_SHADOW_OFFSET * 0.5)
	_stars_box.draw_colored_polygon(shadow, Config.COLOR_OUTLINE)
	_stars_box.draw_colored_polygon(pts, color)
	pts.append(pts[0])
	_stars_box.draw_polyline(pts, Config.COLOR_OUTLINE, 6.0, true)
