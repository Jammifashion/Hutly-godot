class_name LevelLoader
extends RefCounted
## Laedt Level-Daten aus levels/level_XX.json.
##
## Format:
## { "rings": [ { "radius_index": 0, "speed": 0.25, "direction": 1,
##                "glasses": ["blau", "", "rot", ...] }, ... ] }
## Leerer String oder null = leerer Platz. Plaetze werden gleichmaessig verteilt.


## Gibt die Level-Daten zurueck. Fehlt die Datei, wird das hoechste
## vorhandene Level darunter verwendet (mit Warnung).
static func load_level(number: int) -> Dictionary:
	var n := number
	while n >= 1:
		var path := Config.LEVEL_PATH_FORMAT % n
		if ResourceLoader.exists(path):
			if n != number:
				push_warning("Level %d fehlt, verwende %s" % [number, path])
			var json := load(path) as JSON
			if json == null or not (json.data is Dictionary):
				push_error("Level-Datei ungueltig: %s" % path)
				return {}
			return json.data
		n -= 1
	push_error("Keine Level-Datei gefunden fuer Level %d" % number)
	return {}
