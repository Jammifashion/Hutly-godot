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

## Punktestand zu Beginn des aktuellen Levels (fuer NOCHMAL).
var level_start_score := 0


## Neuer Durchlauf ab Level 1 (aus dem Menue).
func start_run() -> void:
	score = 0
	level = Config.START_LEVEL
	lives = Config.START_LIVES
	level_start_score = 0


## Wird von der Spielszene beim Start eines Levels aufgerufen.
func begin_level() -> void:
	lives = Config.START_LIVES
	level_start_score = score


## Aktuelles Level wiederholen: Punkte auf Levelstart zuruecksetzen.
func retry_level() -> void:
	score = level_start_score


func next_level() -> void:
	level += 1
