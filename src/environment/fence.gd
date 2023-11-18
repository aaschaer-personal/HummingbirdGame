class_name Fence extends Interactable

@onready var perch_zone = $PerchZone
@export var is_horizontal = true

func is_interactable():
	return player.held_item == null

func on_clicked(point: Vector2):
	if is_interactable():
		var target_point = point
		if is_horizontal:
			target_point.y = perch_zone.global_position.y
		else:
			target_point.x = perch_zone.global_position.x
		
		player.set_interaction_target(
				"start_perch_h",
				perch_zone,
				player.landing_area,
				perch_zone,
				target_point,
			)
