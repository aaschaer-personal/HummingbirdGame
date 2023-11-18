class_name Item extends Interactable

@onready var item_sprite = $Item
@onready var disk_sprite = $TransportDisk
@onready var item_shadow = $Item/ShadowGenerator
@onready var disk_shadow = $TransportDisk/ShadowGenerator

@export var pickup_height = 4
@export var drop_duration = .1

func _ready():
	disk_sprite.visible = false

func is_interactable():
	return !disk_sprite.visible and get_parent() is Main and player.held_item == null

func get_player_interaction():
	return "pickup"

func get_player_interaction_area():
	return player.pickup_area

func set_flip_h(val: bool):
	item_sprite.set_flip_h(val)

func set_pickup_height():
	item_shadow.height_off_ground = pickup_height

func drop():
	var position_tween = create_tween()
	position_tween.tween_property(
		self,
		"global_position",
		self.global_position + Vector2(0, pickup_height),
		drop_duration,
	)
	tween_height(0, drop_duration)

func transport(x, y):
	disk_sprite.visible = true
	var starting_pos = self.global_position
	
	var duration = abs(x/30.0)
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		self,
		"global_position",
		starting_pos + Vector2(x, 0),
		duration,
	)
	await tween.finished
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		self,
		"global_position",
		starting_pos + Vector2(x, y),
		.4,
	)
	tween_height(0, .4)
	await tween.finished
	disk_sprite.visible = false

func tween_height(target: int, duration: float):
	var item_tween = create_tween()
	var disk_tween = create_tween()
	item_tween.tween_property(
		item_shadow,
		"height_off_ground",
		target,
		duration,
	)
	disk_tween.tween_property(
		disk_shadow,
		"height_off_ground",
		target,
		duration,
	)
