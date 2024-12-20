extends NinePatchRect

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var exit_button = $VBoxContainer/ExitButton
@onready var options = $Options
@onready var level_1 = preload("res://src/levels/level_1.tscn")

func _ready():
	play_button.pressed.connect(play)
	options_button.pressed.connect(open_options_menu)
	exit_button.pressed.connect(exit)

func play():
	get_tree().change_scene_to_packed(level_1)

func open_options_menu():
	options.visible = true

func exit():
	get_tree().quit()
