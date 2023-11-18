class_name BagCrate extends Interactable

@onready var bag_crate_ui = $BagCrateUI

func is_interactable():
	return player.held_item == null or player.held_item is SeedBag

func on_clicked(point: Vector2):
	if is_interactable():
		player.set_interaction_target(
			"open_bag_crate_ui",
			self.bag_crate_ui,
			player.general_interaction_area,
			self,
			point,
		)
