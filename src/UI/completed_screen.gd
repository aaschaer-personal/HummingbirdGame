extends NinePatchRect

@onready var onwards_button = $HBoxContainer/OnwardsButton
@onready var stay_button = $HBoxContainer/StayButton

func _ready():
	onwards_button.pressed.connect(go_to_map)
	stay_button.pressed.connect(close)
	
func open():
	var level = get_tree().get_first_node_in_group("level")
	var config = Config.get_config()
	config.set_value("levels", "last_complete", level.level_num)
	Config.save_config()
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false

func go_to_map():
	get_tree().paused = false
	var map = load("res://src/map/map.tscn")
	get_tree().change_scene_to_packed(map)
