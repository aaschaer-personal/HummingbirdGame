class_name Plant extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var grow_timer = $GrowTimer
@onready var flower_1_scene = preload("res://src/flowers/lupine_1.tscn")
@onready var flower_2_scene = preload("res://src/flowers/lupine_2.tscn")
@onready var flower_3_scene = preload("res://src/flowers/lupine_3.tscn")
@onready var flower_1_spawn = $FlowerSpawn1
@onready var flower_2_spawn = $FlowerSpawn2
@onready var flower_3_spawn = $FlowerSpawn3
@onready var genome = $Genome

var growth = 0
var stage = 0
var current_flowers = 0
var total_flowers = 0
var flowers = [null, null, null]
var parent_plot: Plot

func _ready():
	sprite.play("seed")
	parent_plot = get_parent()

func _process(delta):
	# first put energy into growing
	if _flowers_left_to_grow():
		var growth_nutrients = 0
		if stage == 2:
			growth_nutrients += .5
		if parent_plot.wetness >= delta * genome.water_efficiency:
			growth_nutrients += delta
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
	if growth >= genome.growth_threshold:
		growth = 0
		if stage == 0:
			sprite.play("sprout")
			await sprite.animation_finished
			stage = 1
		elif stage == 1:
			sprite.play("grow")
			await sprite.animation_finished
			stage = 2
		elif stage == 2:
			if _flowers_left_to_grow():
				start_new_flower()

	# die if all flowers are gone
	if stage == 2 and current_flowers == 0 and not _flowers_left_to_grow():
		await get_tree().create_timer(0.2).timeout
		sprite.play("die")
		await sprite.animation_finished
		queue_free()

func _flowers_left_to_grow():
	return total_flowers < genome.max_total_flowers

func rustle():
	if stage == 1 and sprite.animation != "grow":
		sprite.play("sprout_rustle")
	elif stage == 2:
		sprite.play("plant_rustle")

func start_new_flower():
	var flower_scenes = [flower_1_scene, flower_2_scene, flower_3_scene]
	var flower_spawns = [flower_1_spawn, flower_2_spawn, flower_3_spawn]
	var positions = range(3)
	positions.shuffle()
	for i in positions:
		if flowers[i] == null:
			var flower_instance = flower_scenes[i].instantiate()
			flower_instance.flower_position = i
			flowers[i] = flower_instance
			flower_spawns[i].add_child(flower_instance)
			total_flowers += 1
			current_flowers += 1
			GameProgression.unlock_flower(genome.species, genome.flower_color)
			return

func on_flower_harvest(flower_position):
	current_flowers -= 1
	flowers[flower_position] = null
