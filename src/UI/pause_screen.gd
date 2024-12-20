class_name PauseScreen extends ColorRect

signal guide_opened

@onready var pause_menu = $PauseMenu
@onready var guide = $Guide
@onready var options = $Options
@onready var resume_button = $PauseMenu/VBoxContainer/ResumeButton
@onready var guide_button = $PauseMenu/VBoxContainer/GuideButton
@onready var options_button = $PauseMenu/VBoxContainer/OptionsButton
@onready var restart_level_button = $PauseMenu/VBoxContainer/RestartLevelButton
# @onready var return_to_map_button = $PauseMenu/VBoxContainer/ReturnToMapButton
@onready var quit_to_menu_button = $PauseMenu/VBoxContainer/QuitToMenuButton


func _ready():
	resume_button.pressed.connect(resume)
	guide_button.pressed.connect(open_guide)
	options_button.pressed.connect(open_options)
	restart_level_button.pressed.connect(restart_level)
	# return_to_map_button.pressed.connect(return_to_map)
	quit_to_menu_button.pressed.connect(quit_to_menu)

# reset guide visibility on any Esc press
func _input(event):
	if event.is_action_released("Esc"):
		pause_menu.visible = true
		guide.visible = false

func open_guide():
	guide.visible = true
	guide_opened.emit()
	
func open_options():
	options.visible = true

func resume():
	visible = false
	get_tree().paused = false

func restart_level():
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func quit_to_menu():
	get_tree().paused = false
	var main_menu = load("res://src/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)
