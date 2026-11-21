extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

func get_player_interaction():
	return "drop_item_at_point"
	
func get_player_interaction_area():
	return player.pickup_area
