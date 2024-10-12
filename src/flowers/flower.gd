class_name Flower extends Interactable

@onready var parent_plant = get_parent().get_parent()
@onready var main_sprite = $MainSprite
@onready var petal_sprite = $MainSprite/PetalSprite
@onready var pollination_timer = $PollinationTimer
@onready var nectar_meter = $NectarMeter
@onready var drinkable_area = $DrinkableArea
@onready var rustle_audio_player = $RustleAudioPlayer
@onready var bee_audio_player = $BeeAudioPlayer
@onready var bee_scene = preload("res://src/flowers/bee.tscn")

var flower_position: int
var nectar: float = 0.0
var max_nectar: float = 30.0
var stage: int = 0
var seed_growth: float = 0.0
var pollen = []
var seeds = []
var bee: Bee = null
var manualy_pollinated = false

# preloaded by subclasses
var cut_flower_scene

func _ready():
	pollination_timer.timeout.connect(_wilt)
	body_entered.connect(_on_body_entered)
	nectar_meter.max_value = max_nectar
	nectar_meter.visible = false
	petal_sprite.modulate = parent_plant.genome.flower_color
	_play_animation("bloom")
	await main_sprite.animation_finished
	stage = 1
	nectar = max_nectar / (parent_plant.genome.max_flowers * 3)
	SignalBus.flower_bloomed.emit(parent_plant.genome.flower_color)

func _play_animation(animation_name):
	main_sprite.play(animation_name)
	petal_sprite.play(animation_name)
	#if animation_name in ["bloom", "bloom_rustle", "wilt"]:
	# 	petal_sprite.visible = true
	#	petal_sprite.play(animation_name)
	#else:
	#	petal_sprite.visible = false

func receive_nutrients(amount: float):
	if stage == 1:
		nectar += amount * .75
		if nectar >= max_nectar:
			nectar = max_nectar
			if pollination_timer.is_stopped():
				pollination_timer.start(20)
			if not bee:
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

	elif stage == 2:
		seed_growth += amount
		if seed_growth > parent_plant.genome.growth_factor / 2:
			_go_to_seed()

func _on_body_entered(_body):
	rustle()

func rustle():
	var current = main_sprite.animation
	if stage == 1 and current != "wilt":
		_play_animation("bloom_rustle")
	elif stage == 2 and current != "to_seed":
		_play_animation("wilt_rustle")
	elif stage == 3:
		_play_animation("to_seed_rustle")
	rustle_audio_player.set_pitch_scale(randf_range(.9, 1.1))
	rustle_audio_player.play()

func _wilt():
	_play_animation("wilt")
	pollination_timer.stop()
	generate_seeds()
	if bee:
		bee.fly_away()
		bee = null
		bee_audio_player.stop()
	nectar = 0
	stage = 2

func _go_to_seed():
	_play_animation("to_seed")
	await main_sprite.animation_finished
	stage = 3

func is_interactable():
	return (
		(stage == 1 and not player.held_item is Clippers)
		or (stage == 3 and player.held_item is SeedPacket)
		or (player.held_item is Clippers)
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

func _pick_pollen():
	pollen.shuffle()
	for potential in pollen:
		if potential["species"] == parent_plant.genome.species:
			return potential

func generate_seeds():
	for i in range(parent_plant.genome.seed_num):
		var pollen_genome_dict = _pick_pollen()
		if not pollen_genome_dict:
			pollen_genome_dict = GenomeGenerator.wild(
				parent_plant.genome.species)
		var new_seed = GenomeGenerator.genome_dict_from_gamete_dicts(
			GenomeGenerator.gamete_dict_from_genome_dict(
				pollen_genome_dict),
			GenomeGenerator.gamete_dict_from_genome_dict(
				parent_plant.genome.genome_dict)
		)
		if new_seed["species"] == "Sunflower":
			SignalBus.flower_pollinated.emit(
				GenomeHelpers.sunflower_flower_color(new_seed["color"])
			)
		seeds.append(new_seed)

func harvest_seeds(seed_packet):
	seed_packet.add_seeds(seeds)
	harvest()

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
	pollen = player.pollen.duplicate()
	if stage == 1 and pollen:
		manualy_pollinated = true
		pollination_timer.start(1)
	player.add_pollen(parent_plant.genome.genome_dict)

func clip():
	if stage == 1:
		var cut_flower_instance = cut_flower_scene.instantiate()
		get_node("/root/Main").add_child(cut_flower_instance)
		cut_flower_instance.set_color(parent_plant.genome.flower_color)
		cut_flower_instance.set_global_position(global_position)
	harvest()

func harvest():
	parent_plant.on_flower_harvest(flower_position)
	queue_free()
