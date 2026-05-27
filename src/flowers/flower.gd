class_name Flower extends Interactable

@onready var parent_plant = get_parent().get_parent()
@onready var petal_sprite = $PetalSprite
@onready var main_sprite = $MainSprite
@onready var pollination_timer = $PollinationTimer
@onready var nectar_meter = $NectarMeter
@onready var collision_shape = $CollisionShape2D
@onready var drinkable_area = $DrinkableArea
@onready var rustle_audio_player = $RustleAudioPlayer
@onready var bee_audio_player = $BeeAudioPlayer
@onready var bee_hover_points = $BeeHoverPoints
@onready var bee_scene = preload("res://src/flowers/bee.tscn")

var flower_position: int
var nectar: float = 0.0
var max_nectar: float = 30.0
var stage: int = 0
var seed_growth: float = 0.0
var pollen: Array[Dictionary] = []
var seeds = []
var bee: Bee = null
var manualy_pollinated = false
var cut_flower_scene = null
var disable_bees
var color

var cut_offsets = {
	0: Vector2(0,0),
	1: Vector2(-5,1),
	2: Vector2(5,1),
}

func _ready():
	super()
	cut_flower_scene = get_tree().get_first_node_in_group("level").cut_flower_scene

	var options = get_tree().get_first_node_in_group("options")
	options.disable_bees_changed.connect(set_disable_bees)
	set_disable_bees(Config.get_option("disable_bees"))
	pollination_timer.timeout.connect(_go_to_seed)
	body_entered.connect(_on_body_entered)
	nectar_meter.max_value = max_nectar
	nectar_meter.visible = false
	color = parent_plant.genome.flower_color
	if color == Colors.yellow:
		add_to_group("yellow_flowers")
	elif color == Colors.red:
		add_to_group("red_flowers")
	petal_sprite.modulate = color
	_play_animation("bloom")
	await main_sprite.animation_finished
	stage = 1
	nectar = max_nectar / (parent_plant.genome.max_flowers * 3)
	SignalBus.flower_bloomed.emit(color)

func flip():
	main_sprite.flip_h = true
	petal_sprite.flip_h = true
	collision_shape.position.x *= -1
	var collision_shape2 = get_node_or_null("CollisionShape2D2")
	if collision_shape2:
		collision_shape2.position.x *= -1
	drinkable_area.position.x *= -1
	nectar_meter.position.x *= -1
	nectar_meter.position.x -= 12
	for bee_hover_point in bee_hover_points.get_children():
		bee_hover_point.position.x *= -1
	if arrow:
		arrow.position.x *= -1

func _play_animation(animation_name):
	main_sprite.play(animation_name)
	petal_sprite.play(animation_name)

func receive_nutrients(amount: float):
	if stage == 1:
		nectar += amount * .75
		if nectar >= max_nectar:
			nectar = max_nectar
			if pollination_timer.is_stopped() and not disable_bees:
				pollination_timer.start(20)
			if not bee and not disable_bees:
				var new_bee = bee_scene.instantiate()
				add_child(new_bee)
				bee = new_bee
				bee_audio_player.play()
		else:
			if not pollination_timer.is_stopped() and not manualy_pollinated:
				pollination_timer.stop()
			if bee:
				bee.fly_away()
				bee = null
				bee_audio_player.stop()
		nectar_meter.value = nectar

func _on_body_entered(_body):
	rustle()

func rustle():
	var current = main_sprite.animation
	if stage == 1 and current != "to_seed":
		_play_animation("bloom_rustle")
	elif stage == 2:
		_play_animation("to_seed_rustle")
	rustle_audio_player.set_pitch_scale(randf_range(.9, 1.1))
	rustle_audio_player.play()

func _go_to_seed():
	pollination_timer.stop()
	generate_seeds()
	await _play_animation("to_seed")
	if bee:
		bee.fly_away()
		bee = null
		bee_audio_player.stop()
	nectar = 0
	stage = 2
	if parent_plant.genome.species == "sunflower":
		for gene_dict in seeds:
			if GenomeHelpers.color_from_gene_dict(gene_dict) == Colors.orange:
				add_to_group("orange_seeds")

func is_interactable():
	return (
		(stage == 1 and not player.held_item is Clippers)
		or (stage == 2 and player.held_item is SeedPacket)
		or (stage > 0 and player.held_item is Clippers)
	)

func get_player_interaction():
	if stage == 1 and not player.held_item is Clippers:
		return "start_drink"
	else:
		return "use_tool_on_flower"

func get_player_interaction_area():
	if stage == 1 and not player.held_item is Clippers:
		return player.drinking_area
	else:
		return player.general_interaction_area

func get_interaction_area():
	if stage == 1 and not player.held_item is Clippers:
		return drinkable_area
	else:
		return self

func generate_seeds():
	for i in range(parent_plant.genome.seed_num):
		var pollen_gene_dict = pollen.pop_back()
		if not pollen_gene_dict:
			pollen_gene_dict = GenomeGenerator.wild_gene_dict(parent_plant.genome.species)

		var new_seed = GenomeGenerator.offspring_from_parent_genome_dicts(
			pollen_gene_dict,
			parent_plant.genome.gene_dict,
		)

		SignalBus.flower_pollinated.emit(
			GenomeHelpers.color_from_gene_dict(new_seed)
		)
		seeds.append(new_seed)

func harvest_seeds(seed_packet):
	seed_packet.add_seeds(seeds)
	for gene_dict in seeds:
		if GenomeHelpers.color_from_gene_dict(gene_dict) == Colors.orange:
			SignalBus.orange_seeds_harvested.emit()
			break
	remove()

func drink(delta):
	pollination_timer.stop()
	nectar_meter.visible = true
	if stage == 1:
		var amount = min(20 * delta, nectar)
		nectar -= amount
		nectar_meter.value = nectar
		return amount
	else:
		return 0

func finish_drink():
	nectar_meter.visible = false

	if (not pollen) and player.pollen:
		for i in range(4):
			pollen.append(player.pollen.pop_back())

	if stage == 1 and pollen:
		manualy_pollinated = true
		pollination_timer.start(1)

	var new_pollen: Array[Dictionary] = []
	for i in range(8):
		new_pollen.append(parent_plant.genome.gene_dict)
	player.add_pollen(new_pollen)

func clip():
	if stage == 1:
		var cut_flower_instance = cut_flower_scene.instantiate()
		get_tree().get_first_node_in_group("level").add_child(cut_flower_instance)
		if color == Colors.yellow:
			cut_flower_instance.add_to_group("cut_yellow_flowers")
		cut_flower_instance.set_color(color)
		cut_flower_instance.set_global_position(global_position + cut_offsets[flower_position])
		cut_flower_instance.sync_shadow_position()
		# 1 is top, fall opposite of player
		if flower_position == 0:
			cut_flower_instance.fall(player.global_position.x > global_position.x)
		# left if not flipped
		elif flower_position == 1:
			cut_flower_instance.fall(not parent_plant.flipped)
		# right if not flipped
		elif flower_position == 2:
			cut_flower_instance.fall(parent_plant.flipped)
	SignalBus.flower_cut.emit()
	remove()

func remove():
	parent_plant.on_flower_removed(flower_position)
	queue_free()

func set_disable_bees(toggle_value):
	disable_bees = toggle_value
	if toggle_value:
		if bee:
			bee.queue_free()
			bee = null
			bee_audio_player.stop()
		if not manualy_pollinated:
			pollination_timer.stop()
