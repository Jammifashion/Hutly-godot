class_name Glass
extends Node2D
## Ein Glas auf einem Ring. Fuellt sich pro Treffer, platzt wenn voll.

const FONT := preload("res://ui/comic_font.tres")

var type_id := ""
var hits_total := 1
var hits_left := 1
var points := 0
var color := Color.WHITE
var slot_angle := 0.0
var radius := Config.GLASS_DIAMETER * 0.5
var alive := true

var _liquid := 0.0 # angezeigter Fuellstand 0..1
var _sprite: Sprite2D
var _wobble_tween: Tween


func setup(id: String, angle: float) -> void:
	var t: Dictionary = Config.GLASS_TYPES[id]
	type_id = id
	hits_total = t["hits"]
	hits_left = hits_total
	points = t["points"]
	color = t["color"]
	slot_angle = angle

	_sprite = Sprite2D.new()
	_sprite.texture = load(t["texture"])
	_sprite.scale = Vector2.ONE * Config.GLASS_DIAMETER / (Config.GLASS_SVG_DIAMETER * Config.SVG_IMPORT_SCALE)
	_sprite.show_behind_parent = true # Fluessigkeit und Badge liegen darueber
	add_child(_sprite)


func _process(_delta: float) -> void:
	# Glas bleibt aufrecht, auch wenn der Ring sich dreht (Badge immer oben rechts).
	global_rotation = 0.0


## Registriert einen Treffer. Gibt true zurueck, wenn das Glas jetzt voll ist.
func hit() -> bool:
	if not alive:
		return false
	hits_left -= 1
	var fill := 1.0 - float(hits_left) / hits_total
	create_tween().tween_method(_set_liquid, _liquid, fill, Config.GLASS_LIQUID_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_wobble()
	if hits_left <= 0:
		alive = false
		return true
	queue_redraw()
	return false


## Platz-Animation, danach wird das Glas entfernt.
func pop() -> void:
	if _wobble_tween:
		_wobble_tween.kill()
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * Config.GLASS_POP_SCALE, Config.GLASS_POP_TIME) \
		.set_ease(Tween.EASE_OUT)
	t.tween_property(self, "modulate:a", 0.0, Config.GLASS_POP_TIME)
	t.chain().tween_callback(queue_free)


func _wobble() -> void:
	if _wobble_tween:
		_wobble_tween.kill()
	_wobble_tween = create_tween()
	_wobble_tween.tween_property(self, "scale", Config.GLASS_HIT_SQUASH, Config.GLASS_HIT_IN_TIME)
	_wobble_tween.tween_property(self, "scale", Vector2.ONE, Config.GLASS_HIT_OUT_TIME) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _set_liquid(v: float) -> void:
	_liquid = v
	queue_redraw()


func _draw() -> void:
	if _liquid > 0.0:
		var r := radius * Config.GLASS_LIQUID_MAX_RATIO * clampf(_liquid, 0.0, 1.2)
		draw_circle(Vector2.ZERO, r, color)
		draw_circle(Vector2(-r * 0.35, -r * 0.35), r * 0.22, Color(1, 1, 1, 0.8))

	if alive:
		var center := Config.GLASS_BADGE_OFFSET * radius
		var br := Config.GLASS_BADGE_RADIUS
		draw_circle(center, br + 4.0, Config.COLOR_OUTLINE)
		draw_circle(center, br, Config.COLOR_WHITE)
		var fs := Config.GLASS_BADGE_FONT_SIZE
		var baseline := center + Vector2(-br, (FONT.get_ascent(fs) - FONT.get_descent(fs)) * 0.5)
		draw_string(FONT, baseline, str(hits_left), HORIZONTAL_ALIGNMENT_CENTER, br * 2.0,
			fs, Config.COLOR_OUTLINE)
