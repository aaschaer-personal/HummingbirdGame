class_name Fence extends Interactable

@onready var perch_zone = $PerchZone
@export var is_horizontal = true

func is_interactable():
	return player.held_item == null

func get_interaction_target():
	return perch_zone

func get_player_interaction():
	return "start_perch"

func get_player_interaction_area():
	return player.landing_area
	
func get_interaction_area():
	return perch_zone

func get_interaction_point(selection_point: Vector2):
	var target_point = selection_point
	if is_horizontal:
		target_point.y = perch_zone.global_position.y
	else:
		target_point.x = perch_zone.global_position.x
	return target_point
