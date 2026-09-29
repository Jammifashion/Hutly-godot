class_name RingField
extends Node2D
## Alle Ringe eines Levels. Liegt in der Hutmitte, schiebt die Ringe
## langsam nach innen und meldet Treffer, geplatzte Glaeser und Gefahr.

signal glass_hit(glass: Glass, local_pos: Vector2)
signal glass_popped(glass: Glass, local_pos: Vector2)
signal danger_touched(glass: Glass, local_pos: Vector2)
signal cleared

var danger_radius := 200.0
var active := true

var _rings: Array[GlassRing] = []
var _offset := 0.0 # px, um die alle Ringe nach innen gerueckt sind
var _start_delay := Config.PRESSURE_START_DELAY
var _danger_cooldown := 0.0
var _pushing := false


func build(level: Dictionary) -> void:
	var ring_data: Array = level.get("rings", [])
	for data in ring_data:
		var ring := GlassRing.new()
		ring.setup(data)
		add_child(ring)
		_rings.append(ring)
	_rings.sort_custom(func(a: GlassRing, b: GlassRing) -> bool: return a.radius_index < b.radius_index)
	for i in range(1, _rings.size()):
		if _rings[i].direction == _rings[i - 1].direction:
			push_warning("Ring %d und %d drehen gleichlaeufig" % [_rings[i - 1].radius_index, _rings[i].radius_index])
	_apply_offset()


func alive_count() -> int:
	var n := 0
	for ring in _rings:
		n += ring.glasses.size()
	return n


func _process(delta: float) -> void:
	if not active:
		return
	if _start_delay > 0.0:
		_start_delay -= delta
	elif not _pushing:
		_offset += Config.PRESSURE_SPEED * delta
	_apply_offset()

	_danger_cooldown = maxf(0.0, _danger_cooldown - delta)
	if _danger_cooldown <= 0.0:
		_check_danger()


func _apply_offset() -> void:
	for ring in _rings:
		ring.set_radius(ring.base_radius - _offset)


func _check_danger() -> void:
	var limit := danger_radius + Config.DANGER_RING_WIDTH * 0.5 + Config.GLASS_DIAMETER * 0.5
	for ring in _rings:
		if ring.glasses.is_empty() or ring.radius > limit:
			continue
		# Das oberste Glas des Rings bekommt die Sprechblase (gut sichtbar).
		var best: Glass = ring.glasses[0]
		for g in ring.glasses:
			if ring.glass_center(g).y < ring.glass_center(best).y:
				best = g
		_danger_cooldown = Config.DANGER_COOLDOWN
		_push_back()
		danger_touched.emit(best, ring.glass_center(best))
		return


func _push_back() -> void:
	_pushing = true
	var t := create_tween()
	t.tween_property(self, "_offset", _offset - Config.PRESSURE_PUSHBACK, Config.PRESSURE_PUSHBACK_TIME) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_callback(func() -> void: _pushing = false)


## Sucht das erste lebende Glas, das ein Kreis (Radius r) auf dem Weg
## von p0 nach p1 beruehrt. Koordinaten im Ringfeld-System.
## Rueckgabe: {} oder {"glass", "point" (Mitte des Tropfens beim Kontakt)}
func find_first_hit(p0: Vector2, p1: Vector2, r: float) -> Dictionary:
	var d := p1 - p0
	var a := d.length_squared()
	var best_t := INF
	var best: Glass = null
	for ring in _rings:
		for g in ring.glasses:
			var c := ring.glass_center(g)
			var rr := g.radius + r
			var f := p0 - c
			var cc := f.length_squared() - rr * rr
			var t := INF
			if cc <= 0.0:
				t = 0.0 # startet bereits in Beruehrung
			elif a > 0.0:
				var b := 2.0 * f.dot(d)
				var disc := b * b - 4.0 * a * cc
				if disc >= 0.0:
					var t0 := (-b - sqrt(disc)) / (2.0 * a)
					if t0 >= 0.0 and t0 <= 1.0:
						t = t0
			if t < best_t:
				best_t = t
				best = g
	if best == null:
		return {}
	return {"glass": best, "point": p0 + d * best_t}


## Wendet einen Treffer auf das Glas an und meldet ggf. Platzen / Sieg.
func apply_hit(g: Glass) -> void:
	var ring := g.get_parent() as GlassRing
	var pos := ring.glass_center(g)
	var popped := g.hit()
	glass_hit.emit(g, pos)
	if popped:
		ring.remove_glass(g)
		g.pop()
		glass_popped.emit(g, pos)
		if alive_count() == 0:
			cleared.emit()
