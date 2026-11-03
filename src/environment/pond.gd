class_name Pond extends StaticBody2D

@onready var splash_zone = $SplashZone
@onready var player = get_tree().get_first_node_in_group("player")

func is_interactable():
	return player.held_item == null or player.held_item is WateringCan

func get_player_interaction():
	if player.held_item == null:
			return "bathe"
	elif player.held_item is WateringCan:
		return "refill_can"

func get_player_interaction_area():
	return player.landing_area
	
func get_interaction_area():
	return splash_zone

func get_interaction_point(selection_point: Vector2):
	if Helpers.point_in_area(selection_point, splash_zone):
		return selection_point
	else:
		return splash_zone.global_position
