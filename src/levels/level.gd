class_name Level extends Node

@onready var player = $Player
@onready var cache = $Cache
@onready var drop_point = $DropPoint
@onready var visitor_manager = $VisitorManager
@onready var intro_screen = $UI/IntroScreen
@onready var completed_screen = $UI/CompletedScreen
@onready var tutorial_container = $UI/TutorialScroll/TutorialContainer
@onready var pause_screen = $UI/PauseScreen
@onready var pause_button = $UI/PauseButton
@onready var failure_screen = $UI/FailureScreen
@onready var seed_packet_scene = preload("res://src/items/seed_packet.tscn")
@onready var control_text_scene = preload("res://src/UI/control_text.tscn")

var flower_accepted = false
var visitor_left = false
var flowers_grown = 0
var colors_grown = {}
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
	SignalBus.plant_died.connect(_failure_check)
	SignalBus.cut_flower_decayed.connect(_failure_check)
	SignalBus.flower_accepted.connect(_on_flower_accepted)
	visitor_manager.visitor_left.connect(_on_visitor_left)
	visitor_manager.initialize_bouquets(bouquet_recipes)
	GenomeGenerator.initialize_next_gene_storage(flower_species)
	pause_button.toggled.connect(_on_pause_button_toggled)
	SignalBus.paused_or_unpaused.connect(_on_paused_or_unpaused)
	main.call_deferred()

func _on_paused_or_unpaused():
	pause_button.set_pressed_no_signal(get_tree().paused)

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

func _on_pause_button_toggled(toggle_on):
	if toggle_on:
		# don't overlap menus
		if cache.cache_ui.visible or intro_screen.visible:
			pause_button.toggled = false
		elif not pause_screen.visible:
			pause_screen.visible = true
			get_tree().paused = true
			SignalBus.paused.emit()
	else:
		pause_screen.guide.visible = false
		pause_screen.visible = false
		if pause_screen.options.visible:
			pause_screen.options.close()
		get_tree().paused = false
		SignalBus.unpaused.emit()

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
	intro_screen.text.text = level_intro_text
	intro_screen.open()
	player.controllable = true
	await cache.dispense_all(generate_starting_packet())
