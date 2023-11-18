class_name PauseScreen extends ColorRect

@onready var cache_ui = get_tree().get_first_node_in_group("cache_ui")

func _input(event):
	if event.is_action_released("Esc"):
		if cache_ui.visible:
			cache_ui.close()
		else:
			var flag = get_tree().paused
			get_tree().paused = not flag
			visible = not flag
