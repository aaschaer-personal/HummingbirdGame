class_name Item extends RigidBody2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var item_sprite = $Item
@onready var disk_sprite = $TransportDisk
@onready var item_shadow = $Item/ShadowGenerator
@onready var disk_shadow = $TransportDisk/ShadowGenerator
@onready var disk_audio = $TransportDiskAudio

@export var ground_height = 0
@export var pickup_height = 4
@export var drop_duration = .15

var dispense_slot = null

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	disk_sprite.visible = false

func is_interactable():
	return !disk_sprite.visible and get_parent() is Level

func get_player_interaction():
	return "pickup"

func get_player_interaction_area():
	return player.pickup_area

func set_flip_h(val: bool):
	item_sprite.set_flip_h(val)

func set_pickup_height():
	item_shadow.height_off_ground = pickup_height

func drop():
	# restore ground collision
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	# drop
	tween_height(ground_height, drop_duration)
	freeze = false
	gravity_scale = 1.0
	await get_tree().create_timer(drop_duration, false).timeout
	gravity_scale = 0.0
	linear_velocity = Vector2(0,0)
	freeze = true

func transport(x, y):
	disk_sprite.visible = true
	disk_audio.playing = true
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
	tween_height(ground_height, .4)
	await tween.finished
	disk_sprite.visible = false
	disk_audio.playing = false

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
