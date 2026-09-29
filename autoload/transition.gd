extends CanvasLayer
## Szenenwechsel mit Wisch-Ueberblendung (Autoload "Transition").
## Aufruf: Transition.go_to(Config.SCENE_GAME)

var _progress := 0.0 # 0..1 Wisch rein, 1..2 Wisch raus
var _busy := false
var _wipe: Control


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_wipe = Control.new()
	_wipe.set_anchors_preset(Control.PRESET_FULL_RECT)
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wipe.draw.connect(_draw_wipe)
	add_child(_wipe)


func is_busy() -> bool:
	return _busy


func go_to(scene_path: String) -> void:
	if _busy:
		return
	_busy = true
	_wipe.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween_in := create_tween()
	tween_in.tween_method(_set_progress, 0.0, 1.0, Config.TRANSITION_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween_in.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame

	var tween_out := create_tween()
	tween_out.tween_method(_set_progress, 1.0, 2.0, Config.TRANSITION_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween_out.finished

	_set_progress(0.0)
	_wipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func _set_progress(value: float) -> void:
	_progress = value
	_wipe.queue_redraw()


func _draw_wipe() -> void:
	if _progress <= 0.0 or _progress >= 2.0:
		return
	var vs := _wipe.get_viewport_rect().size
	var skew := Config.TRANSITION_SKEW
	var far := vs.x + skew * 2.0
	var left_edge := -far
	var right_edge := far
	if _progress <= 1.0:
		right_edge = lerpf(-skew * 0.5, vs.x + skew * 0.5, _progress)
	else:
		left_edge = lerpf(-skew * 0.5, vs.x + skew * 0.5, _progress - 1.0)

	var s := skew * 0.5
	var body := PackedVector2Array([
		Vector2(left_edge + s, 0), Vector2(right_edge + s, 0),
		Vector2(right_edge - s, vs.y), Vector2(left_edge - s, vs.y),
	])
	_wipe.draw_colored_polygon(body, Config.COLOR_SKY)

	# Comic-Kanten: gelber Streifen mit schwarzer Kontur an den Wischkanten
	for edge in [right_edge, left_edge]:
		if absf(edge) >= far:
			continue
		var e := Config.TRANSITION_EDGE
		var dir := 1.0 if edge == right_edge else -1.0
		var band := PackedVector2Array([
			Vector2(edge + s - e * dir, 0), Vector2(edge + s, 0),
			Vector2(edge - s, vs.y), Vector2(edge - s - e * dir, vs.y),
		])
		_wipe.draw_colored_polygon(band, Config.COLOR_YELLOW)
		_wipe.draw_line(Vector2(edge + s, 0), Vector2(edge - s, vs.y),
			Config.COLOR_OUTLINE, Config.OUTLINE_WIDTH)
		_wipe.draw_line(Vector2(edge + s - e * dir, 0), Vector2(edge - s - e * dir, vs.y),
			Config.COLOR_OUTLINE, Config.OUTLINE_WIDTH)
