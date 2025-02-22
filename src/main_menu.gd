extends NinePatchRect

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var options = $Options

func _ready():
	play_button.pressed.connect(play)
	options_button.pressed.connect(open_options_menu)
	exit_button.pressed.connect(exit)

func play():
	var scene
	var config = Config.get_config()
	if config.get_value("levels", "completed", 0) > 0 or config.get_value("levels", "last_complete", 0) == 1:
		scene = load("res://src/map/map.tscn")
	else:
		scene = load("res://src/levels/level_1.tscn")
	get_tree().change_scene_to_packed(scene)

func open_options_menu():
	options.visible = true

func exit():
	get_tree().quit()
