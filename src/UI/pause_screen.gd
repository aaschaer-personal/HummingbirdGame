class_name PauseScreen extends ColorRect

@onready var bag_crate_ui = get_tree().get_first_node_in_group("bag_crate_ui")

func _input(event):
	if event.is_action_released("Esc"):
		if bag_crate_ui.visible:
			bag_crate_ui.close()
		else:
			var flag = get_tree().paused
			get_tree().paused = not flag
			visible = not flag
