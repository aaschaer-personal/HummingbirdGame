extends AudioStreamPlayer2D

@export var option = "effects_volume"
@export var db_offset = 0
@onready var options = get_tree().get_first_node_in_group("options")
var global_offset = -20

func _ready():
	var config = Config.get_config()
	var volume = config.get_value("options", option, 50)
	volume_db = linear_to_db(volume) + db_offset + global_offset
	options.volume_changed.connect(_on_volume_changed)

func _on_volume_changed(changed_option, new_volume):
	if changed_option == option:
		volume_db = linear_to_db(new_volume) + db_offset + global_offset
