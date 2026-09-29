class_name DangerRing
extends Node2D
## Rote gestrichelte Gefahrenlinie als Kreis um den Hut.

var radius := 200.0:
	set(v):
		radius = v
		queue_redraw()


func _process(delta: float) -> void:
	rotation = wrapf(rotation + Config.DANGER_RING_SPEED * delta, 0.0, TAU)


func _draw() -> void:
	var step_len := Config.DANGER_RING_DASH + Config.DANGER_RING_GAP
	var count := maxi(8, int(TAU * radius / step_len))
	var step := TAU / count
	var dash := step * Config.DANGER_RING_DASH / step_len
	var w := Config.DANGER_RING_WIDTH
	for i in count:
		var a := i * step
		draw_arc(Vector2.ZERO, radius, a, a + dash, 8, Config.COLOR_OUTLINE, w + 6.0, true)
	for i in count:
		var a := i * step
		draw_arc(Vector2.ZERO, radius, a + 0.004, a + dash - 0.004, 8, Config.COLOR_RED, w, true)
