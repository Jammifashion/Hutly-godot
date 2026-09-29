extends Node
## Globaler Spielstand (Autoload "GameState").

signal score_changed(value: int)
signal level_changed(value: int)
signal lives_changed(value: int)

var score := 0:
	set(value):
		score = value
		score_changed.emit(score)

var level := Config.START_LEVEL:
	set(value):
		level = value
		level_changed.emit(level)

var lives := Config.START_LIVES:
	set(value):
		lives = value
		lives_changed.emit(lives)


func start_run() -> void:
	score = 0
	level = Config.START_LEVEL
	lives = Config.START_LIVES
