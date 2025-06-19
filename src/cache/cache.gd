class_name Cache extends Interactable

signal packet_printed

@onready var front = $Front
@onready var left_door = $LeftDoor
@onready var right_door = $RightDoor
@onready var back = $Back
@onready var shadow = $Shadow
@onready var cache_ui = $CacheUI
@onready var watering_can_scene = preload("res://src/items/watering_can.tscn")
@onready var clippers_scene = preload("res://src/items/clippers.tscn")

@onready var audio_player = $OptionAwareAudioPlayer
@onready var raise_sound = preload("res://assets/Sounds/cache_raise.wav")
@onready var door_sound = preload("res://assets/Sounds/door.wav")

var PACKET_START = Vector2(-2, -22)
var PACKET_TRANSPORT = Vector2(-73, 6)
var CAN_START = Vector2(0, -24)
var CAN_TRANSPORT = Vector2(-55, 6)
var CLIPPER_START = Vector2(4, -19)
var CLIPPER_TRANSPORT = Vector2(-36, 6)

# 3 initial slots plus up to 10 printed packets
var dispense_slots = [true, true, true, false, false, false, false, false, false, false, false, false, false]
var packets_printing = 0
var door_open = false
var top
var top_positions = [0,0,0,0,0,0,-1,-3,-5,-8,-11,-14,-17,-19,-20]

func _ready():
	front.frame_changed.connect(sync_frames)
	var top_scene = get_tree().get_first_node_in_group("level").cache_top_scene
	while top_scene == null:
		pass
	top = top_scene.instantiate()
	front.add_child(top)
	var shadow_pos = shadow.global_position
	var shadow_canvas_group = get_tree().get_first_node_in_group("shadow_canvas_group")
	Helpers.set_parent(shadow, shadow_canvas_group)
	shadow.global_position = shadow_pos
	player.dispense_slot_pickup.connect(_on_dispense_slot_pickup)

func sync_frames():
	var frame = front.get_frame()
	var progress = front.get_frame_progress()
	back.set_frame_and_progress(frame, progress)
	left_door.set_frame_and_progress(frame, progress)
	right_door.set_frame_and_progress(frame, progress)
	shadow.set_frame_and_progress(frame, progress)
	top.position = Vector2(0,top_positions[frame])

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
	shadow.play("raise")
	top.position = Vector2(0, -20)
	front.set_frame_and_progress(14, 0)
	back.set_frame_and_progress(14, 0)
	left_door.set_frame_and_progress(14, 0)
	right_door.set_frame_and_progress(14, 0)
	shadow.set_frame_and_progress(14, 0)

func raise():
	front.play("raise")
	back.play("raise")
	left_door.play("raise")
	right_door.play("raise")
	shadow.play("raise")
	audio_player.stream = raise_sound
	audio_player.play()
	await front.animation_finished

func _play_door_sound():
	audio_player.stream = door_sound
	audio_player.play()

func left_door_open():
	left_door.play("open")
	_play_door_sound()
	await left_door.animation_finished
	
func right_door_open():
	right_door.play("open")
	_play_door_sound()
	await left_door.animation_finished

func left_door_close():
	left_door.play_backwards("open")
	_play_door_sound()

func right_door_close ():
	right_door.play_backwards("open")
	_play_door_sound()

func quick_dispense_all(seed_packet):
	seed_packet.global_position = self.global_position + PACKET_START + PACKET_TRANSPORT
	seed_packet.dispense_slot = 2

	var watering_can = watering_can_scene.instantiate()
	self.add_sibling(watering_can)
	watering_can.global_position = self.global_position + CAN_START + CAN_TRANSPORT
	watering_can.dispense_slot = 1

	var clippers = clippers_scene.instantiate()
	self.add_sibling(clippers)
	clippers.global_position =  self.global_position + CLIPPER_START + CLIPPER_TRANSPORT
	clippers.dispense_slot = 0
	
func dispense_all(seed_packet):
	await left_door_open()
	_dispense_seeds(seed_packet)
	await get_tree().create_timer(0.7, false).timeout
	_dispense_watering_can()
	await get_tree().create_timer(0.7, false).timeout
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
	seed_packet.global_position = self.global_position + PACKET_START
	seed_packet.tween_height(4, 0)
	seed_packet.dispense_slot = 2
	await seed_packet.transport(PACKET_TRANSPORT.x, PACKET_TRANSPORT.y)

func _dispense_watering_can():
	var watering_can = watering_can_scene.instantiate()
	self.add_sibling(watering_can)
	watering_can.global_position = self.global_position + CAN_START
	watering_can.dispense_slot = 1
	watering_can.tween_height(4, 0)
	await watering_can.transport(CAN_TRANSPORT.x, CAN_TRANSPORT.y)
	
func _dispense_clippers():
	var clippers = clippers_scene.instantiate()
	self.add_sibling(clippers)
	clippers.global_position = self.global_position + CLIPPER_START
	clippers.dispense_slot = 0
	clippers.tween_height(4, 0)
	await clippers.transport(CLIPPER_TRANSPORT.x, CLIPPER_TRANSPORT.y)

func print_packet(seed_packet):
	if not door_open:
		await left_door_open()
		door_open = true
	seed_packet.tween_height(4, 0)
	
	packets_printing += 1
	var dispense_slot = 0
	for i in range(13):
		if not dispense_slots[i]:
			dispense_slot = i
			dispense_slots[i] = true
			break
	seed_packet.dispense_slot = dispense_slot
		
	await seed_packet.transport(-10 + (-21 * (dispense_slot + 1)), 6)
	packet_printed.emit()
	packets_printing -= 1

	if packets_printing == 0:
		door_open = false
		left_door_close()

func _on_dispense_slot_pickup(slot):
	dispense_slots[slot] = false
