extends Node2D

@onready var level = get_tree().get_first_node_in_group("level")
@onready var tutorial_container = get_tree().get_first_node_in_group("tutorial_container")
@onready var player = get_tree().get_first_node_in_group("player")
@onready var cache = get_tree().get_first_node_in_group("cache")
@onready var watering_can = get_tree().get_first_node_in_group("watering_can")
@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")
@onready var completed_screen = get_tree().get_first_node_in_group("completed_screen")
@onready var failure_screen = get_tree().get_first_node_in_group("failure_screen")
@onready var visitor_manager = get_tree().get_first_node_in_group("visitor_manager")
@onready var seed_packet_scene = preload("res://src/items/seed_packet.tscn")
@onready var control_text_scene = preload("res://src/UI/control_text.tscn")

var water_explained = false
var energy_explained = false
var packet_printed = false
var seeds_harvested = false
var visitor_left = false
var flowers_grown = 0
var colors_grown = {}
var colors_pollinated = {}
var BRIEF_PAUSE = .5

func _ready():
	var options = get_tree().get_first_node_in_group("options")
	options.show_tutorial_changed.connect(set_tutorial_visibility)
	SignalBus.flower_bloomed.connect(_on_flower_bloomed)
	SignalBus.flower_pollinated.connect(_on_flower_pollinated)
	SignalBus.plant_died.connect(_failure_check)
	SignalBus.cut_flower_decayed.connect(_failure_check)
	SignalBus.flower_accepted.connect(_failure_check)
	SignalBus.watering_can_emptied.connect(_on_watering_can_emptied)
	cache.packet_printed.connect(_on_packet_printed)
	visitor_manager.visitor_left.connect(_on_visitor_left)
	player.energy_quartered.connect(_on_energy_quartered)
	player.seeds_harvested.connect(_on_seeds_harvested)
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
	
func _on_seeds_harvested():
	seeds_harvested = true

func _on_energy_quartered():
	if not energy_explained:
		energy_explained = true
		add_tutorial_text("Energy",
		"""Restore your energy:

1. Perch on the sapling (left click or %interact) to stop energy loss and restore up to a third of your energy.
2. Drink nectar from flowers.

""")
		await player.energy_back_to_half
		await remove_tutorial_text("Energy")

func _on_watering_can_emptied():
	if not water_explained:
		water_explained = true
		add_tutorial_text("Water",
		"""Refill the watering can:

Interact with the pond (click or %interact) while holding the watering can.

""")
	await SignalBus.watering_can_refilled
	await remove_tutorial_text("Water")

func generate_starting_packet():
	var packet = seed_packet_scene.instantiate()
	packet.global_position = Vector2(-100,-100)
	add_sibling(packet)
	var starting_seeds = level.generate_starting_seeds()
	starting_seeds.shuffle()
	packet.add_seeds(starting_seeds)
	return packet

func main():
	if Config.get_option("skip_intros"):
		await quick_intro_sequence()
	else:
		await cinematic_intro_sequence()
	if level.level_num == 1:
		set_tutorial_visibility(Config.get_option("show_tutorial"))
		tutorial_sequence()
	else:
		water_explained = true
		energy_explained = true

func quick_intro_sequence():
	cache.quick_raise()
	cache.quick_dispense_all(generate_starting_packet())
	player.global_position = Vector2(140,180)
	player.controllable = true

func move_player_on_screen():
	player.global_position = Vector2(-100,180)
	player.move_to_point(Vector2(140,180), true)
	await player.motion_finished

func cinematic_intro_sequence():
	player.controllable = false
	await move_player_on_screen()
	await cache.raise()
	player.controllable = true
	await cache.dispense_all(generate_starting_packet())

func add_tutorial_text(text_name: String, template: String):
	var tutorial_text = control_text_scene.instantiate()
	tutorial_text.name = text_name
	tutorial_text.set_template(template)
	tutorial_container.add_child(tutorial_text)
	tutorial_text.fade_in()

func remove_tutorial_text(text_name):
	for tutorial_text in tutorial_container.get_children():
		if tutorial_text.name == text_name:
			await tutorial_text.fade_out()
			break

func tutorial_sequence():
	add_tutorial_text("Title", "Tutorial:\n\n")
	await get_tree().create_timer(.2, false).timeout
	
	add_tutorial_text("Guide",
"""Open the guide:

1. Press %pause to open the pause menu.
2. Click on Guide.
3. Close with %exit_menu.
4. Reference back as needed!

""")
	await pause_screen.guide_opened
	await remove_tutorial_text("Guide")

	if flowers_grown < 6:
		add_tutorial_text("GrowFlowers",
"""Grow four sunflower plants:

1. Pick up a seed packet (click or %interact).
2. Plant seeds in bare soil (click or %interact while holding a seed packet).
3. Drop the seed packet (right click or %drop).
4. Pick up the watering can (click or %interact).
5. Water seeds (move while holding watering can).
6. Drop the watering can (right click or %drop).
7. Wait for the flowers to grow.

""")
		
		while true:
			await SignalBus.flower_bloomed
			if flowers_grown >= 6:
				await remove_tutorial_text("GrowFlowers")
				break

	if Colors.orange not in colors_pollinated:
		add_tutorial_text("OrangePollination",
	"""Cross-pollinate for an orange sunflower:

1. If there is any pollen on your beak, take a bath in the pond (click or %interact).
2. Drink from a red or yellow sunflower (click or %interact).
3. Drink from the other collor sunflower (click or %interact).

""")
		while true:
			await SignalBus.flower_pollinated
			if Colors.orange in colors_pollinated:
				break
		await remove_tutorial_text("OrangePollination")

	if not packet_printed:
		add_tutorial_text("PrintPacket",
"""Print a new seed packet:

1. Open the cache (click or %interact).
2. Select a color, icon, and/or icon color.
3. Press print.

""")
		await cache.packet_printed
		await remove_tutorial_text("PrintPacket")

	if not seeds_harvested:
		add_tutorial_text("HarvestSeeds",
"""Harvest orange sunflower seeds:

1. Wait for the cross pollinated flower to go to seed.
2. Pick up a seed packet (click or %interact).
3. Harvest the seeds (click or %interact while holding a seed packet).

""")
		await player.seeds_harvested
		await remove_tutorial_text("HarvestSeeds")

	if not Colors.orange in colors_grown:
		add_tutorial_text("OrangeGrow",
"""Grow an orange sunflower:

1. Plant one of the cross-pollinated seeds.
2. Water them and wait for the flower to grow.

""")
		while true:
			await SignalBus.flower_bloomed
			if Colors.orange in colors_grown:
				break
		await remove_tutorial_text("OrangeGrow")

	if not visitor_left:
		add_tutorial_text("SatisfyVisitor",
"""Satisfy a visitor:

1. Grow a flower the visitor wants.
2. Cut the flower (click or %interact while holding clippers).
3. Pick up the cut flower (click or %interact).
4. Deliver the flower to the vistitor (click %interact while holding the flower).

""")
		await visitor_manager.visitor_left
		await remove_tutorial_text("SatisfyVisitor")

	add_tutorial_text("FinishLevel",
"""Finish the level:

Satisfy five visitors in total to finish the level.

""")

func set_tutorial_visibility(toggle_value):
	tutorial_container.visible = toggle_value
