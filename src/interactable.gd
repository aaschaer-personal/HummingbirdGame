class_name Interactable extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

func is_interactable():
	return true

func get_player_interaction():
	pass
	
func get_interaction_target():
	return self

func get_player_interaction_area():
	return player.general_interaction_area

func get_interaction_area():
	return self

func get_interaction_point(_selection_point: Vector2):
	return get_interaction_area().global_position

func on_selected(_selection_point: Vector2):
	if is_interactable():
		player.set_interaction_target(
				get_player_interaction(),
				get_interaction_target(),
				get_player_interaction_area(),
				get_interaction_area(),
				get_interaction_point(_selection_point),
			)
