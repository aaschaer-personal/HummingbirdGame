class_name Level extends Node

@onready var player = $Player
@onready var cache = $Cache
@onready var visitor_manager = $VisitorManager
@onready var intro_scene = $UI/IntroScreen
@onready var completed_screen = $UI/CompletedScreen
@onready var tutorial_container = $UI/TutorialContainer
@onready var pause_screen = $UI/PauseScreen
@onready var failure_screen = $UI/FailureScreen
@onready var seed_packet_scene = preload("res://src/items/seed_packet.tscn")
@onready var control_text_scene = preload("res://src/UI/control_text.tscn")

var water_explained = false
var energy_explained = false
var packet_printed = false
var orange_seeds_harvested = false
var flower_accepted = false
var visitor_left = false
var flowers_grown = 0
var colors_grown = {}
var colors_pollinated = {}
var starting_packet = null
var BRIEF_PAUSE = .5

# abstract
var level_num
var level_intro_text
var bouquet_recipes
var flower_species

func generate_starting_seeds():
	pass

func _ready():
	SignalBus.flower_bloomed.connect(_on_flower_bloomed)
	SignalBus.flower_pollinated.connect(_on_flower_pollinated)
	SignalBus.plant_died.connect(_failure_check)
	SignalBus.cut_flower_decayed.connect(_failure_check)
	SignalBus.flower_accepted.connect(_on_flower_accepted)
	cache.packet_printed.connect(_on_packet_printed)
	visitor_manager.visitor_left.connect(_on_visitor_left)
	SignalBus.orange_seeds_harvested.connect(_on_orange_seeds_harvested)
	visitor_manager.initialize_bouquets(bouquet_recipes)
	GenomeGenerator.initialize_next_gene_storage(flower_species)

	main.call_deferred()

func _failure_check():
	if visitor_manager.done:
		return
	for seed_packet in get_tree().get_nodes_in_group("seed_packets"):
		if len(seed_packet.seeds) > 0:
			return
	for plant in get_tree().get_nodes_in_group("plants"):
		if plant.current_flowers or plant._flowers_left_to_grow():
			return
	for cut_flower in get_tree().get_nodes_in_group("cut_flowers"):
		if cut_flower.is_in_play():
			return
	failure_screen.open()

func _on_flower_accepted():
	flower_accepted = true
	_failure_check()

func _on_visitor_left():
	visitor_left = true
	if visitor_manager.done:
		var tween = create_tween()
		tween.tween_property(
			tutorial_container, "modulate", Color.TRANSPARENT, .2
		)
		await tween.finished
		completed_screen.open()

func _on_flower_bloomed(color):
	flowers_grown += 1
	colors_grown[color] = true
	if not visitor_manager.visitors_unlocked:
		visitor_manager.visitors_unlocked = true
		visitor_manager.timer.start(1)

func _on_flower_pollinated(color):
	colors_pollinated[color] = true

func _on_packet_printed():
	packet_printed = true
	
func _on_orange_seeds_harvested():
	orange_seeds_harvested = true

func main():
	if Config.get_option("skip_intros"):
		await quick_intro_sequence()
	else:
		await cinematic_intro_sequence()

func generate_starting_packet():
	starting_packet = seed_packet_scene.instantiate()
	starting_packet.global_position = Vector2(-100,-100)
	add_child(starting_packet)
	var starting_seeds = generate_starting_seeds()
	starting_seeds.shuffle()
	starting_packet.add_seeds(starting_seeds)
	return starting_packet

func quick_intro_sequence():
	cache.quick_raise()
	cache.quick_dispense_all(generate_starting_packet())
	player.global_position = Vector2(130,180)
	player.controllable = true

func move_player_on_screen():
	player.global_position = Vector2(-100,180)
	player.move_to_point(Vector2(130,180), true)
	await player.motion_finished

func cinematic_intro_sequence():
	player.controllable = false
	await move_player_on_screen()
	await cache.raise()
	intro_scene.text.text = level_intro_text
	intro_scene.open()
	player.controllable = true
	await cache.dispense_all(generate_starting_packet())
