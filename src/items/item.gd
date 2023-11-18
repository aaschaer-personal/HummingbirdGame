class_name Item extends Interactable

@onready var sprite = $Sprite2D

func is_interactable():
	return get_parent() is Main and player.held_item == null

func on_clicked(_point: Vector2):
	if is_interactable():  # don't try to pickup items in inventory slots
		player.set_interaction_target(
			"pickup",
			self,
			player.pickup_area,
			self,
			self.global_position
		)

func set_flip_h(val):
	sprite.flip_h = val
