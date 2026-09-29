extends Control
## Leerer Platzhalter-Screen (Hutregal, Einstellungen) mit Zurueck-Button.

@export var screen_title := "PLATZHALTER"

@onready var title: Label = $Titel
@onready var info: Label = $Info
@onready var back: ComicButton = $Zurueck


func _ready() -> void:
	title.text = screen_title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", Config.PLACEHOLDER_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", Config.COLOR_YELLOW)
	title.add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	title.add_theme_constant_override("outline_size", Config.MENU_TITLE_OUTLINE / 2)

	info.text = "Kommt bald!"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", Config.PLACEHOLDER_TEXT_FONT_SIZE)
	info.add_theme_color_override("font_color", Config.COLOR_WHITE)
	info.add_theme_color_override("font_outline_color", Config.COLOR_OUTLINE)
	info.add_theme_constant_override("outline_size", Config.LEVEL_OUTLINE)

	back.text = "ZURÜCK"
	back.font_size = Config.MENU_BUTTON_FONT_SIZE
	back.pressed.connect(_back_to_menu)

	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var vs := get_viewport_rect().size
	$Sonnenstrahlen.position = vs * 0.5
	title.position = Vector2(0, vs.y * 0.2)
	title.size = Vector2(vs.x, Config.PLACEHOLDER_TITLE_FONT_SIZE * 1.5)
	info.position = Vector2(0, vs.y * 0.45)
	info.size = Vector2(vs.x, Config.PLACEHOLDER_TEXT_FONT_SIZE * 1.5)
	back.size = Config.PLACEHOLDER_BACK_SIZE
	back.position = Vector2((vs.x - back.size.x) * 0.5, vs.y * 0.75)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back_to_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_back_to_menu()


func _back_to_menu() -> void:
	Transition.go_to(Config.SCENE_MENU)
