class_name Cache extends Interactable

signal packet_printed

@onready var front = $Front
@onready var left_door = $LeftDoor
@onready var right_door = $RightDoor
@onready var back = $Back
@onready var cache_ui = $CacheUI
@onready var watering_can_scene = preload("res://src/items/watering_can.tscn")
@onready var clippers_scene = preload("res://src/items/clippers.tscn")

var packets_printing = 0
var door_open = false

func _ready():
	front.frame_changed.connect(sync_frames)

func sync_frames():
	var frame = front.get_frame()
	var progress = front.get_frame_progress()
	back.set_frame_and_progress(frame, progress)
	left_door.set_frame_and_progress(frame, progress)
	right_door.set_frame_and_progress(frame, progress)

func is_interactable():
	return player.held_item == null or player.held_item is SeedPacket

func get_player_interaction():
	return "open_cache_ui"

func get_interaction_target():
	return self.cache_ui

func get_interaction_point(selection_point: Vector2):
	return selection_point

func quick_raise():
	front.play("raise")
	back.play("raise")
	left_door.play("raise")
	right_door.play("raise")
	front.set_frame_and_progress(14, 0)
	back.set_frame_and_progress(14, 0)
	left_door.set_frame_and_progress(14, 0)
	right_door.set_frame_and_progress(14, 0)

func raise():
	front.play("raise")
	back.play("raise")
	left_door.play("raise")
	right_door.play("raise")
	await front.animation_finished

func left_door_open():
	left_door.play("open")
	await left_door.animation_finished
	
func right_door_open():
	right_door.play("open")
	await left_door.animation_finished

func left_door_close():
	left_door.play_backwards("open")

func right_door_close ():
	right_door.play_backwards("open")

func quick_dispense_all(seed_packet):
	seed_packet.generate_starting_seeds()
	seed_packet.global_position = self.global_position + Vector2(-2, -22) + Vector2(-78, 8)

	var watering_can = watering_can_scene.instantiate()
	self.add_sibling(watering_can)
	watering_can.global_position = self.global_position + Vector2(0, -24) + Vector2(-60, 8)

	var clippers = clippers_scene.instantiate()
	self.add_sibling(clippers)
	clippers.global_position =  self.global_position + Vector2(4, -23) + Vector2(-40, 8)

func dispense_all(seed_packet):
	await left_door_open()
	_dispense_seeds(seed_packet)
	await get_tree().create_timer(0.7).timeout
	_dispense_watering_can()
	await get_tree().create_timer(0.7).timeout
	await _dispense_clippers()
	left_door_close()

func dispense_seeds(seed_packet):
	await left_door_open()
	await _dispense_seeds(seed_packet)
	left_door_close()
	
func dispense_watering_can():
	await left_door_open()
	await _dispense_watering_can()
	left_door_close()
	
func dispense_clippers():
	await left_door_open()
	await _dispense_clippers()
	left_door_close()

func _dispense_seeds(seed_packet):
	seed_packet.global_position = self.global_position + Vector2(-2, -22)
	seed_packet.tween_height(4, 0)
	await seed_packet.transport(-78, 6)

func _dispense_watering_can():
	var watering_can = watering_can_scene.instantiate()
	self.add_sibling(watering_can)
	watering_can.global_position = self.global_position + Vector2(0, -24)
	watering_can.tween_height(4, 0)
	await watering_can.transport(-60, 6)
	
func _dispense_clippers():
	var clippers = clippers_scene.instantiate()
	self.add_sibling(clippers)
	clippers.global_position = self.global_position + Vector2(4, -23)
	clippers.tween_height(4, 0)
	await clippers.transport(-40, 6)

func print_packet(seed_packet):
	if not door_open:
		await left_door_open()
		door_open = true
	seed_packet.global_position = self.global_position + Vector2(-2, -22)
	seed_packet.tween_height(4, 0)
	while packets_printing > 3:
		await get_tree().create_timer(0.1).timeout
	packets_printing += 1
	await seed_packet.transport(-10 + (-20 * packets_printing), 6)
	packet_printed.emit()
	packets_printing -= 1

	if packets_printing == 0:
		door_open = false
		left_door_close()
