extends Node2D
## Untergrund "Holzdielen". Austauschbar: jede Node namens "Boden",
## die den Bildschirm fuellt, kann diese Szene-Node ersetzen.


func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)


func _draw() -> void:
	var vs := get_viewport_rect().size
	var m := Config.FLOOR_MARGIN
	var rng := RandomNumberGenerator.new()
	rng.seed = Config.PLANK_SEED
	var h := Config.PLANK_HEIGHT
	var colors := Config.PLANK_COLORS

	var y := -m
	while y < vs.y + m:
		var x := -m - rng.randf_range(0.0, Config.PLANK_MAX_LENGTH)
		while x < vs.x + m:
			var length := rng.randf_range(Config.PLANK_MIN_LENGTH, Config.PLANK_MAX_LENGTH)
			var rect := Rect2(x, y, length, h)
			draw_rect(rect, colors[rng.randi() % colors.size()])
			# Maserung
			for g in 3:
				var gy := y + h * (0.25 + 0.25 * g) + rng.randf_range(-8.0, 8.0)
				var gx := x + rng.randf_range(20.0, length * 0.3)
				var gl := rng.randf_range(length * 0.3, length * 0.6)
				draw_line(Vector2(gx, gy), Vector2(gx + gl, gy + rng.randf_range(-6.0, 6.0)),
					Config.PLANK_GRAIN_COLOR, 4.0, true)
			# Stossfuge mit Naegeln
			draw_line(Vector2(x, y), Vector2(x, y + h), Config.PLANK_SEAM_COLOR, Config.PLANK_SEAM_WIDTH)
			for ny in [y + h * 0.25, y + h * 0.75]:
				draw_circle(Vector2(x + 18.0, ny), 6.0, Config.PLANK_NAIL_COLOR)
				draw_circle(Vector2(x + length - 18.0, ny), 6.0, Config.PLANK_NAIL_COLOR)
			x += length
		# Laengsfuge
		draw_line(Vector2(-m, y), Vector2(vs.x + m, y), Config.PLANK_SEAM_COLOR, Config.PLANK_SEAM_WIDTH)
		y += h
