class_name Plant extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var grow_timer = $GrowTimer
@onready var flower_1_spawn = $FlowerSpawn1
@onready var flower_2_spawn = $FlowerSpawn2
@onready var flower_3_spawn = $FlowerSpawn3
@onready var genome = $Genome
@onready var audio_player = $OptionAwareAudioPlayer

var flower_1_scene = null
var flower_2_scene = null
var flower_3_scene = null
var growth = 0
var stage = 0
var dying = false
var current_flowers = 0
var total_flowers = 0
var flowers = [null, null, null]
var parent_plot: Plot

func _ready():
	var level = get_tree().get_first_node_in_group("level")
	flower_1_scene = level.flower_1_scene
	flower_2_scene = level.flower_2_scene
	flower_3_scene = level.flower_3_scene
	add_to_group("plants")
	sprite.play("seed")
	parent_plot = get_parent()

func _process(delta):
	# first put energy into growing
	if _flowers_left_to_grow():
		var growth_nutrients = 0
		if stage >= 1:
			growth_nutrients += delta / 2 # base 0.5 g/s even if not watered
		if parent_plot.wetness >= delta * genome.water_efficiency:
			growth_nutrients += delta # extra 1 g/s when watered
			parent_plot.dry(delta * genome.water_efficiency)
		growth += growth_nutrients

	# then send nutrients to flowers
	var flower_nutrients = delta / 2.0  # base 0.5 n/s even if not watered
	if parent_plot.wetness >= delta * genome.water_efficiency:
		flower_nutrients += delta  # extra 1 n/s when watered
		parent_plot.dry(delta * genome.water_efficiency)
	for flower in flowers:
		if flower != null:
			flower.receive_nutrients(flower_nutrients / current_flowers)

	# check for growth thresholds
	if growth >= genome.growth_factor:
		growth = 0
		if stage == 0:
			z_index += 1
			sprite.play("sprout")
			await sprite.animation_finished
			stage = 1
		elif stage == 1:
			sprite.play("grow")
			await sprite.animation_finished
			stage = 2
		elif stage == 2:
			while _flowers_left_to_grow():
				start_new_flower()

	# die if all flowers are gone
	if stage == 2 and current_flowers <= 0 and not _flowers_left_to_grow() and not dying:
		dying = true
		await get_tree().create_timer(0.2, false).timeout
		sprite.play("die")
		await sprite.animation_finished
		SignalBus.plant_died.emit()
		queue_free()

func _flowers_left_to_grow():
	return total_flowers < genome.max_flowers

func rustle():
	audio_player.set_pitch_scale(randf_range(.9, 1.1))
	if stage == 1 and sprite.animation != "grow":
		sprite.play("sprout_rustle")
		audio_player.play()
	elif stage == 2 and sprite.animation != "die":
		sprite.play("plant_rustle")
		audio_player.play()

func _rand_flower_positions():
	var positions = range(3)
	positions.shuffle()
	return positions

func start_new_flower():
	var flower_scenes = [flower_1_scene, flower_2_scene, flower_3_scene]
	var flower_spawns = [flower_1_spawn, flower_2_spawn, flower_3_spawn]
	var positions = _rand_flower_positions()
	for i in positions:
		if flowers[i] == null:
			var flower_instance = flower_scenes[i].instantiate()
			flower_instance.flower_position = i
			flowers[i] = flower_instance
			flower_spawns[i].add_child(flower_instance)
			total_flowers += 1
			current_flowers += 1
			return

func on_flower_harvest(flower_position):
	current_flowers -= 1
	flowers[flower_position] = null
