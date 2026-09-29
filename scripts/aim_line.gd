class_name AimLine
extends Node2D
## Gestrichelte Ziellinie. Liegt in der Hutmitte, zeigt entlang +x;
## die Node wird von game.gd auf den Zielwinkel gedreht.

var start_distance := 150.0
var _scroll := 0.0


func _ready() -> void:
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	var step := Config.AIM_DASH + Config.AIM_DASH_GAP
	_scroll = fmod(_scroll + Config.AIM_DASH_SPEED * delta, step)
	queue_redraw()


func _draw() -> void:
	var w := Config.AIM_LINE_WIDTH
	var start := start_distance
	var stop := start_distance + Config.AIM_LINE_LENGTH
	var step := Config.AIM_DASH + Config.AIM_DASH_GAP
	for pass_outline in [true, false]:
		var color := Config.COLOR_OUTLINE if pass_outline else Config.COLOR_WHITE
		var width := w + 6.0 if pass_outline else w
		var x := start + _scroll - step
		while x < stop:
			var a := maxf(x, start)
			var b := minf(x + Config.AIM_DASH, stop)
			if b > a:
				draw_line(Vector2(a, 0), Vector2(b, 0), color, width)
				draw_circle(Vector2(a, 0), width * 0.5, color)
				draw_circle(Vector2(b, 0), width * 0.5, color)
			x += step
		var end_r := Config.AIM_END_RADIUS + (3.0 if pass_outline else 0.0)
		draw_circle(Vector2(stop + Config.AIM_END_RADIUS * 2.0, 0), end_r, color)
