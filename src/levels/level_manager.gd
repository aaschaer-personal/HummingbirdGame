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

var water_explained = false
var energy_explained = false
var packet_printed = false
var seeds_harvested = false
var visitor_left = false
var flowers_grown = 0
var colors_grown = {}
var colors_pollinated = {}
var BRIEF_PAUSE = .5
var config

func _ready():
	config = Config.get_config()
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

1. Perch on the sapling to stop energy loss and restore up to a third of your energy.
2. Drink nectar from flowers.

""")
	await player.energy_back_to_half
	await remove_tutorial_text("Energy")

func _on_watering_can_emptied():
	if not water_explained:
		water_explained = true
		add_tutorial_text("Water",
		"""Refill the watering can:

1. Interact with the pond while holding the watering can.

""")
	await SignalBus.watering_can_refilled
	await remove_tutorial_text("Water")

func generate_starting_packet():
	var packet = seed_packet_scene.instantiate()
	packet.global_position = Vector2(-100,-100)
	add_sibling(packet)
	
	var starting_seeds = []
	if level.level_num == 1:
		for i in range(4):
			starting_seeds.append(GenomeGenerator.wild("sunflower"))
		starting_seeds[0]["max_flowers"] = 0
		starting_seeds[0]["color"] = ["Y", "Y"]
		starting_seeds[1]["max_flowers"] = 0
		starting_seeds[1]["color"] = ["Y", "Y"]
		starting_seeds[2]["max_flowers"] = 1
		starting_seeds[2]["color"] = ["Y", "Y"]
		starting_seeds[3]["max_flowers"] = 1
		starting_seeds[3]["color"] = ["R", "R"]
	elif level.level_num == 2:
		for i in range(3):
			starting_seeds.append(GenomeGenerator.wild("jewelweed"))
		starting_seeds[0]["max_flowers"] = 1
		starting_seeds[0]["color"] = ["R", "R"]
		starting_seeds[2]["max_flowers"] = 1
		starting_seeds[2]["color"] = ["Y", "Y"]
		starting_seeds[1]["max_flowers"] = 0
		starting_seeds[1]["color"] = ["P", "P"]
	elif level.level_num == 3:
		for i in range(4):
			starting_seeds.append(GenomeGenerator.wild("lupine"))
		starting_seeds[0]["max_flowers"] = 0
		starting_seeds[1]["max_flowers"] = 1
		starting_seeds[2]["red"] = ["r", "r"]
		starting_seeds[2]["blue"] = ["B", "B"]
		starting_seeds[2]["max_flowers"] = 1
		starting_seeds[3]["red"] = ["R", "r"]
		starting_seeds[3]["blue"] = ["b", "b"]
		starting_seeds[3]["max_flowers"] = 1
	elif level.level_num == 4:
		for i in range(3):
			starting_seeds.append(GenomeGenerator.wild("zinnia"))
		starting_seeds[0]["max_flowers"] = 1
		starting_seeds[0]["color"] = ["R", "W"]
		starting_seeds[1]["max_flowers"] = 1
		starting_seeds[1]["color"] = ["R", "Y"]
		starting_seeds[2]["max_flowers"] = 0
		starting_seeds[2]["color"] = ["F", "F"]
	else:
		assert(false)

	starting_seeds.shuffle()
	packet.add_seeds(starting_seeds)
	return packet

func main():
	if config.get_value("options", "quick_start", false):
		await quick_intro_sequence()
	else:
		await cinematic_intro_sequence()
	if level.level_num == 1 and config.get_value("options", "show_tutorial", true):
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

func add_tutorial_text(text_name, text):
	var rtl = RichTextLabel.new()
	rtl.name = text_name
	rtl.text = text
	rtl.fit_content = true
	rtl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rtl.modulate = Color.TRANSPARENT
	tutorial_container.add_child(rtl)
	var tween = create_tween()
	tween.tween_property(
		rtl, "modulate", Color.WHITE, .2
	)
	await tween.finished

func remove_tutorial_text(text_name):
	for rtl in tutorial_container.get_children():
		if rtl.name == text_name:
			var tween = create_tween()
			tween.tween_property(
				rtl, "modulate", Color.TRANSPARENT, .2
			)
			await tween.finished
			rtl.queue_free()
			break

func tutorial_sequence():
	add_tutorial_text("Title", "Tutorial:\n\n")
	await get_tree().create_timer(.2, false).timeout
	
	add_tutorial_text("Guide",
"""Open the guide:

1. Press Esc to open the pause menu.
2. Click on Guide.
3. Close with Esc.
4. Reference back as needed!

""")
	await pause_screen.guide_opened
	await remove_tutorial_text("Guide")

	if flowers_grown < 6:
		add_tutorial_text("GrowFlowers",
"""Grow four sunflower plants:

1. Plant seeds by picking up a seed packet then interacting with bare soil.
2. Drop the seed packet.
3. Water the seeds by picking up the watering can then flying over them.
4. Wait for the flowers to grow.

""")
	while true:
		await SignalBus.flower_bloomed
		if flowers_grown >= 6:
			await remove_tutorial_text("GrowFlowers")
			break

	if Colors.orange not in colors_pollinated:
		add_tutorial_text("OrangePollination",
	"""Cross-pollinate for an orange sunflower:

1. Take a bath if there is any pollen on your beak.
2. Drink from a red or yellow sunflower.
3. Drink from the other collor sunflower.

""")
		while true:
			await SignalBus.flower_pollinated
			if Colors.orange in colors_pollinated:
				break
		await remove_tutorial_text("OrangePollination")

	if not packet_printed:
		add_tutorial_text("PrintPacket",
"""Print a new seed packet:

1. Interact with the cache (the machine that provided your tools and starting seeds).
2. Select a color, icon, and/or icon color.
3. Press print.

""")
		await cache.packet_printed
		await remove_tutorial_text("PrintPacket")

	if not seeds_harvested:
		add_tutorial_text("HarvestSeeds",
"""Harvest seeds:

1. Wait for the cross pollinated flower to go to seed.
2. While holding a seed packet interact with the flower.

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

1. While holding the clipers interact with a flower the visitor wants to cut it.
2. Pick up the cut flower and bring it to the visitor.

""")
		await visitor_manager.visitor_left
		await remove_tutorial_text("SatisfyVisitor")

	add_tutorial_text("FinishLevel",
"""Finish the level:

1. Satisfy five visitors in total to finish the level.

""")
