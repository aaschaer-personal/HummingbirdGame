extends NinePatchRect

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var credits_button = $VBoxContainer/CreditsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var options = $Options
@onready var credits = $Credits

func _ready():
	play_button.pressed.connect(play)
	options_button.pressed.connect(open_options_menu)
	credits_button.pressed.connect(open_credits)
	quit_button.pressed.connect(quit)

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

func open_credits():
	credits.visible = true

func quit():
	visible = false
	get_tree().quit()
