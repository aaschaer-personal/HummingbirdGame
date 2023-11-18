class_name Pond extends Interactable

@onready var splash_zone = $SplashZone

func is_interactable():
	return player.held_item == null or player.held_item is WateringCan

func on_clicked(point: Vector2):
	if is_interactable():
		var target_point
		if Helpers.point_in_area(point, splash_zone):
			target_point = point
		else:
			target_point = splash_zone.global_position

		var action
		if player.held_item == null:
			action = "bathe"
		elif player.held_item is WateringCan:
			action = "refill_can"

		player.set_interaction_target(
			action,
			self,
			player.landing_area,
			splash_zone,
			target_point,
		)
