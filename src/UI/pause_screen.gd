class_name PauseScreen extends ColorRect

signal guide_opened

@onready var pause_menu = $PauseMenu
@onready var guide = $Guide
@onready var options = $Options
@onready var resume_button = $PauseMenu/VBoxContainer/ResumeButton
@onready var guide_button = $PauseMenu/VBoxContainer/GuideButton
@onready var options_button = $PauseMenu/VBoxContainer/OptionsButton
@onready var restart_level_button = $PauseMenu/VBoxContainer/RestartLevelButton
@onready var return_to_map_button = $PauseMenu/VBoxContainer/ReturnToMapButton
@onready var quit_to_menu_button = $PauseMenu/VBoxContainer/QuitToMenuButton
@onready var exit_button = $ExitButton

func _ready():
	resume_button.pressed.connect(resume)
	exit_button.pressed.connect(resume)
	guide_button.pressed.connect(open_guide)
	options_button.pressed.connect(open_options)
	restart_level_button.pressed.connect(restart_level)
	return_to_map_button.pressed.connect(return_to_map)
	quit_to_menu_button.pressed.connect(quit_to_menu)

	# only show return to map if level 1 has been completed
	var config = Config.get_config()
	if config.get_value("levels", "unlocks", 0) > 0:
		return_to_map_button.visible = true

	# hide level specific buttons
	if not get_parent().get_parent() is Level:
		guide_button.visible = false
		restart_level_button.visible = false
		return_to_map_button.visible = false

# reset guide visibility on any Esc press
func _input(event):
	if event.is_action_released("Esc"):
		if guide.visible or options.visible:
			guide.visible = false
			options.visible = false
		else:
			visible = false
			await get_tree().create_timer(0.01).timeout
			get_tree().paused = false

func open_guide():
	guide.visible = true
	guide_opened.emit()
	
func open_options():
	options.visible = true

func resume():
	if not guide.visible:
		visible = false
		get_tree().paused = false
	# hacky way of dealing with overlapping buttons
	else:
		guide.close()

func restart_level():
	get_tree().paused = false
	get_tree().reload_current_scene()

func return_to_map():
	get_tree().paused = false
	var map = load("res://src/map/map.tscn")
	get_tree().change_scene_to_packed(map)

func quit_to_menu():
	get_tree().paused = false
	Config.save_config()
	var main_menu = load("res://src/UI/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)
