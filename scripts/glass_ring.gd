class_name GlassRing
extends Node2D
## Ein drehender Ring mit gleichmaessig verteilten Glas-Plaetzen.

var radius_index := 0
var base_radius := Config.RING_FIRST_RADIUS
var direction := 1
var angular_speed := 0.0 # rad/s inkl. Richtung
var radius := 0.0
var glasses: Array[Glass] = []


func setup(data: Dictionary) -> void:
	radius_index = int(data.get("radius_index", 0))
	base_radius = Config.RING_FIRST_RADIUS + radius_index * Config.RING_SPACING
	direction = 1 if float(data.get("direction", 1)) >= 0.0 else -1
	angular_speed = absf(float(data.get("speed", 0.0))) * direction

	var slots: Array = data.get("glasses", [])
	for i in slots.size():
		var id = slots[i]
		if id == null or str(id) == "":
			continue
		if not Config.GLASS_TYPES.has(str(id)):
			push_warning("Unbekannter Glastyp '%s' in Ring %d" % [id, radius_index])
			continue
		var g := Glass.new()
		g.setup(str(id), TAU * i / slots.size())
		add_child(g)
		glasses.append(g)
	set_radius(base_radius)


func _process(delta: float) -> void:
	rotation = wrapf(rotation + angular_speed * delta, 0.0, TAU)


func set_radius(r: float) -> void:
	radius = r
	for g in glasses:
		g.position = Vector2.from_angle(g.slot_angle) * r


## Glasmitte im Koordinatensystem des Ringfelds (Ring liegt im Ursprung).
func glass_center(g: Glass) -> Vector2:
	return g.position.rotated(rotation)


func remove_glass(g: Glass) -> void:
	glasses.erase(g)
