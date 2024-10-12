class_name Player extends CharacterBody2D

signal motion_finished
signal energy_quartered
signal energy_back_to_half
signal seeds_harvested

@onready var body_sprite = $Animation/Body
@onready var front_wing_sprite = $Animation/FrontWing
@onready var back_wing_sprite = $Animation/BackWing
@onready var pollen_sprite = $Animation/Pollen
@onready var splash_particles = $Animation/SplashParticles
@onready var flippables = $Flippables
@onready var hold_point = $Flippables/HoldPoint
@onready var pickup_area = $Flippables/PickupArea
@onready var general_interaction_area = $Flippables/InteractionArea
@onready var drinking_area = $Flippables/DrinkingArea
@onready var landing_area = $Flippables/LandingArea
@onready var interaction_radius = $InteractionRadius
@onready var bouquet_scene = preload("res://src/items/bouquet.tscn")

@onready var audio_player = $AudioStreamPlayer2D
@onready var humm_player = $HummPlayer
@onready var bath_sound = preload("res://assets/Sounds/bath.wav")
@onready var dirt_sound = preload("res://assets/Sounds/dirt.wav")
@onready var refill_sound = preload("res://assets/Sounds/refill.wav")
@onready var paper_sound = preload("res://assets/Sounds/paper.wav")
@onready var drinking_sound = preload("res://assets/Sounds/drinking.wav")

var base_speed = 200
var moving_time = 0
var quick_turn = false
var max_energy = 120
var energy = max_energy
var interaction = null
var target = null
var interaction_area = null
var target_area = null
var interaction_position = null
var target_point = null
var interaction_direction = null
var held_item = null
var drinking_flower = null
var hovering_frame = 0
var perching_frame = 0
var perch_y = 0
var perch_x = 0
var facing_right = true
var target_animation = "hovering"
var pollen = []
var controllable = false
var in_motion = false
var low_energy_singal_toggle = false

@onready var interaction_point_marker = $IPM
@onready var target_point_marker = $TPM

func _ready():
	general_interaction_area.area_entered.connect(
		_on_interaction_area_entered.bind(general_interaction_area))
	pickup_area.area_entered.connect(
		_on_interaction_area_entered.bind(pickup_area))
	drinking_area.area_entered.connect(
		_on_interaction_area_entered.bind(drinking_area))
	landing_area.area_entered.connect(
		_on_interaction_area_entered.bind(landing_area))

func _input(event):
	if controllable:
		if Input.is_action_just_released("interact"):
			interact_with_nearest_target()
		
		elif Input.is_action_just_released("drop"):
			drop_held_item()
				
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			drop_held_item()

func _process(delta):
	if velocity:
		if drinking_flower:
			drinking_flower.finish_drink()
			drinking_flower = null
		moving_time += delta
		if moving_time >= .2 and energy and held_item == null:
			target_animation = "zooming"
		else:
			target_animation = "hovering"
	else:
		if moving_time:
			motion_finished.emit()
		moving_time = 0
		if target_animation == "zooming":
			target_animation = "hovering"

	if drinking_flower and body_sprite.animation == "drinking":
		var gained_energy = drinking_flower.drink(delta)
		energy += gained_energy
		if gained_energy > 0.1:
			audio_player.set_pitch_scale(
					.4 +  (energy/max_energy) * .6
				)
			if not audio_player.playing:
				audio_player.stream = drinking_sound
				audio_player.play()
		else:
			audio_player.stop()
	elif audio_player.stream == drinking_sound:
		audio_player.stop()

	if body_sprite.animation in ["perching_h", "perching_v"]:
		var rate = (-0.2 * energy) + 6
		rate = max(rate, 0)
		energy += rate * delta
	else:
		energy -= 1 * delta

	if not low_energy_singal_toggle and energy <= (max_energy / 4.0):
			energy_quartered.emit()
			low_energy_singal_toggle = true
	elif low_energy_singal_toggle and energy >= (max_energy / 2.0):
			energy_back_to_half.emit()
			low_energy_singal_toggle = false

	if energy <= 0:
		energy = 0
		drop_held_item()
	elif energy > max_energy:
		energy = max_energy

	_do_animation()

func _physics_process(delta):
	var speed = base_speed
	if energy <= 0:
		speed = base_speed / 2.0
	elif body_sprite.animation == "zooming":
		speed = base_speed * 2
	
	var direction = Vector2.ZERO
	if controllable:
		direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO and target_point:
		_unset_interaction_target()
	if direction == Vector2.ZERO and target_point:
		var interaction_point = global_position + interaction_position
		interaction_point_marker.global_position = interaction_point
		target_point_marker.global_position = target_point

		if interaction_point.distance_to(target_point) >= speed * delta:
			direction = interaction_point.direction_to(target_point)
		else:
			direction = Vector2.ZERO

	velocity = direction * speed
	move_and_slide()

func interact_with_nearest_target():
	var nearest_target = null
	var best_distance = null
	
	for potential_target in interaction_radius.get_overlapping_areas():
		if potential_target is Interactable and potential_target.is_interactable():
			var distance = potential_target.get_player_interaction_area().global_position.distance_to(
				potential_target.get_interaction_area().global_position)
			if best_distance == null or distance < best_distance:
				best_distance = distance
				nearest_target = potential_target

	if nearest_target != null:
		nearest_target.on_selected(nearest_target.global_position)

func move_to_point(new_target_point, overide_controllable=false):
	if controllable or overide_controllable:
		_unset_interaction_target()
		target_point = new_target_point
		interaction_position = Vector2.ZERO

func set_interaction_target(
	new_interaction,
	new_target,
	new_interaction_area,
	new_target_area,
	new_target_point,
):
	if controllable:
		_unset_interaction_target()
		if new_interaction_area.overlaps_area(new_target_area):
			call(new_interaction, new_target)
		else:
			interaction = new_interaction
			target = new_target
			interaction_area = new_interaction_area
			target_area = new_target_area
			target_point = new_target_point

			# calculate interaction position and direction
			var right_position = interaction_area.position
			right_position.x = abs(interaction_area.position.x)
			var left_position = right_position * Vector2(-1, 1)
			if interaction_area == pickup_area:
				right_position *= Vector2(-1, 1)
				left_position *= Vector2(-1, 1)
			var right_point = global_position + right_position
			var left_point = global_position + left_position
			var right_distance = right_point.distance_to(target_point)
			var left_distance = left_point.distance_to(target_point)
			var right_x_distance = abs(right_point.x - target_point.x)
			var left_x_distance = abs(left_point.x - target_point.x)

			# for smaller x distances pick the closer interaction point
			if min(right_x_distance, left_x_distance) < base_speed / 5.0:
				if right_distance < left_distance:
					interaction_position = right_position
					interaction_direction = "right"
				else:
					interaction_position = left_position
					interaction_direction = "left"
			# for longer x distances pick the direction of travel
			else:
				if target_point.x > global_position.x:
					interaction_position = right_position
					interaction_direction = "right"
				else:
					interaction_position = left_position
					interaction_direction = "left"

func _unset_interaction_target():
	interaction = null
	target = null
	interaction_area = null
	target_area = null
	interaction_position = null
	interaction_direction = null
	target_point = null

func _on_interaction_area_entered(entering_area, our_area):
	if (our_area == interaction_area
		and entering_area == target_area
	):
		call_deferred(interaction, target)
		_unset_interaction_target()

func pickup(item):
	if energy > 0:
		if item is CutFlower:
			item.decay_timer.stop()
			if held_item is Bouquet:
				held_item.add_flower(item)
				held_item.set_flip_h(body_sprite.flip_h)
			elif held_item == null:
				var new_bouquet = bouquet_scene.instantiate()
				hold_point.add_child(new_bouquet)
				new_bouquet.add_flower(item)
				item = new_bouquet

		if held_item == null:
			item.reparent(hold_point)
			item.global_position = hold_point.global_position
			item.set_flip_h(body_sprite.flip_h)
			held_item = item
			if not item is Bouquet:
				item.set_pickup_height()


func _drop_item(item):
	item.reparent(get_parent())
	item.drop()

func drop_held_item():
	if held_item:
		if held_item is Bouquet:
			for flower in held_item.get_flowers():
				_drop_item(flower)
				flower.start_decay_timer()
			held_item.queue_free()
			held_item = null
		else:
			_drop_item(held_item)
			held_item = null

func remove_held_item():
	var ret = held_item
	held_item = null
	return ret

func start_drink(flower: Flower):
	if drinking_flower != null and drinking_flower != flower:
		drinking_flower.finish_drink()
	drinking_flower = flower
	target_animation = "drinking"
	
func use_tool_on_flower(flower: Flower):
	if flower.stage == 3 and held_item is SeedPacket:
		flower.harvest_seeds(held_item)
		seeds_harvested.emit()
		audio_player.set_pitch_scale(randf_range(.9, 1.1))
		audio_player.stream = paper_sound
		audio_player.play()
	elif held_item is Clippers:
		flower.clip()
		held_item.audio_player.play()

func use_tool_on_plot(plot: Plot):
	if held_item is SeedPacket:
		if plot.plant == null:
			var removed_seed = held_item.remove_seed()
			if removed_seed != null:
				plot.plant_seed(removed_seed)
				audio_player.set_pitch_scale(randf_range(.9, 1.1))
				audio_player.stream = dirt_sound
				audio_player.play()
		elif plot.plant.stage == 0:
			held_item.add_seeds([plot.remove_seed()])
			audio_player.set_pitch_scale(randf_range(.9, 1.1))
			audio_player.stream = paper_sound
			audio_player.play()

func open_cache_ui(ui: CacheUI):
	if held_item == null or held_item is SeedPacket:
		ui.open()

func start_perch_h(perch_zone: Area2D):
	perch_y = perch_zone.global_position.y
	target_animation = "perching_h"

func give_bouquet(visitor: Visitor):
	if held_item is Bouquet:
		visitor.give_bouquet(held_item)
		if not len(held_item.get_flowers()):
			remove_held_item()

func bathe(_pond):
	if held_item == null:
		target_animation = "bathe"
		# pollen is cleared post animation
		
func refill_can(_pond):
	if held_item is WateringCan:
		held_item.refill()
		audio_player.stream = refill_sound
		audio_player.play()

func transfer_seeds(to_packet):
	if held_item is SeedPacket:
		to_packet.add_seeds(held_item.remove_all_seeds())

func add_pollen(pollen_dict: Dictionary):
	pollen.append(pollen_dict)
	pollen = pollen.slice(-10)
	pollen_sprite.visible = true

func _set_wings(val: bool, sound=true):
	front_wing_sprite.visible = val
	back_wing_sprite.visible = val
	if sound:
		humm_player.playing = val


func _flip_h(val: bool):
	body_sprite.set_flip_h(val)
	front_wing_sprite.set_flip_h(val)
	back_wing_sprite.set_flip_h(val)
	pollen_sprite.set_flip_h(val)

func _play_animation(animation_name):
	body_sprite.play(animation_name)
	pollen_sprite.play(animation_name)
	
func _set_frame(frame):
	body_sprite.set_frame(frame)
	pollen_sprite.set_frame(frame)

func _set_flippables(right: bool):
	if right != (hold_point.position.x < 0):
		for flipabble in flippables.get_children():
			flipabble.position.x *= -1

func _do_animation():
	var current = body_sprite.animation

	# don't interupt non looping animations
	if not body_sprite.sprite_frames.get_animation_loop(current):
		return
	
	# if we were perched, immediatly flip sprite to current direction 
	if facing_right == null:
		if velocity.x > 0:
			_flip_h(false)
			_set_flippables(true)
			facing_right = true
		elif velocity.x < 0:
			_flip_h(true)
			_set_flippables(false)
			facing_right = false

	# check if we should turn
	var turn_flip_val = null  # true: left, false: right
	if interaction_direction != null:
		if interaction_direction == "right" and facing_right == false:
			turn_flip_val = false
		elif interaction_direction == "left" and facing_right == true:
			turn_flip_val = true

	elif moving_time >= .1:
		if (velocity.x < 0) and facing_right == true:
			turn_flip_val = true
		elif (velocity.x > 0) and facing_right == false:
			turn_flip_val = false

	if turn_flip_val != null:
		# save current animation frame, stop wings, and start turn
		var duration = 0.3  # 12 frames at 40fps
		var current_frame = body_sprite.get_frame()
		_set_wings(false, false)
		# flip all flippables
		for flippable in flippables.get_children():
			flippable.position *= Vector2(-1, 1)
		_play_animation("turn")
		# halfway through the turn, turn any hold item
		await get_tree().create_timer(duration / 2.0).timeout
		if held_item:
			held_item.set_flip_h(turn_flip_val)
		await body_sprite.animation_finished
		# start wings and restore previous animation frame
		_set_wings(true)
		facing_right = !turn_flip_val
		_flip_h(turn_flip_val)
		_play_animation(current)
		_set_frame(current_frame)

	# stop if we're already playing the target
	if current == target_animation:
		return

	# if we're hovering we should be one step away from target
	if current == "hovering":
		hovering_frame = body_sprite.get_frame()
		if target_animation == "zooming":
			_play_animation("start_zooming")
			await body_sprite.animation_finished
			_play_animation("zooming")
		elif target_animation == "drinking":
			_play_animation("start_drinking")
			await body_sprite.animation_finished
			_play_animation("drinking")
		elif target_animation == "perching_h":
			_set_wings(false, false)
			_play_animation("start_perching_h")
			var tween = create_tween()
			tween.tween_property(
				self,
				"position",
				Vector2(position.x, perch_y + 15),
				8.0/40.0
			)
			_tween_height(15, 8.0/40.0)
			await body_sprite.animation_finished
			humm_player.playing = false
			facing_right = null
			_play_animation("perching_h")
			_set_frame(perching_frame)
		elif target_animation == "perching_v":
			_set_wings(false)
			_play_animation("start_perching_v")
			await body_sprite.animation_finished
			facing_right = null
			_play_animation("perching_h")
			_set_frame(perching_frame)
		elif target_animation == "bathe":
			controllable = false
			var tween = create_tween()
			tween.tween_property(
				self,
				"position",
				Vector2(position.x, position.y + 16),
				2.0/10.0
			)
			_tween_height(0, 2.0/10.0)
			_play_animation("bathe")
			await get_tree().create_timer(2.0/10.0).timeout
			_set_wings(false)
			await get_tree().create_timer(4.0/10.0).timeout
			splash_particles.emitting = true
			audio_player.set_pitch_scale(1)
			audio_player.stream = bath_sound
			audio_player.play()
			await get_tree().create_timer(6.0/10.0).timeout
			splash_particles.emitting = false
			await get_tree().create_timer(3.0/10.0).timeout
			_set_wings(true)
			controllable = true
			tween = create_tween()
			tween.tween_property(
				self,
				"position",
				Vector2(position.x, position.y - 16),
				2.0/10.0
			)
			_tween_height(15, 2.0/10.0)
			await body_sprite.animation_finished
			pollen = []
			pollen_sprite.visible = false
			
			target_animation = "hovering"
			_play_animation("hovering")

	# otherwise transition to hovering either as intermediate or target
	else:
		if current == "zooming":
			_play_animation("stop_zooming")
		elif current == "drinking":
			_play_animation("stop_drinking")
		elif current == "perching_h":
			perching_frame = body_sprite.get_frame()
			_play_animation("stop_perching_h")
			_tween_height(15, .2)
		elif current == "perching_h":
			perching_frame = body_sprite.get_frame()
			_play_animation("stop_perching_y")
		await body_sprite.animation_finished
		_set_wings(true)
		_play_animation("hovering")
		_set_frame(hovering_frame)

func _tween_height(target_height: int, duration: float):
	var back_wing_tween = create_tween()
	var body_tween = create_tween()
	var front_wing_tween = create_tween()
	back_wing_tween.tween_property(
		$Animation/BackWing/ShadowGenerator,
		"height_off_ground",
		target_height,
		duration,
	)
	body_tween.tween_property(
		$Animation/Body/ShadowGenerator,
		"height_off_ground",
		target_height,
		duration,
	)
	front_wing_tween.tween_property(
		$Animation/FrontWing/ShadowGenerator,
		"height_off_ground",
		target_height,
		duration,
	)
