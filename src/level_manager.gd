extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var cache = get_tree().get_first_node_in_group("cache")
@onready var dialogue = get_tree().get_first_node_in_group("dialogue")
@onready var completed_screen = get_tree().get_first_node_in_group("completed_screen")
@onready var failure_screen = get_tree().get_first_node_in_group("failure_screen")
@onready var visitor_manager = get_tree().get_first_node_in_group("visitor_manager")
@onready var seed_packet_scene = preload("res://src/items/seed_packet.tscn")

var skip_intro = true
var genes_explained = false
var seeds_explained = false
var bees_explained = false
var death_explained = false
var energy_explained = false
var packets_explained = false
var in_tutorial = false
var colors_grown = {}
var BRIEF_PAUSE = .5

func _ready():
	SignalBus.flower_bloomed.connect(_on_flower_bloomed)
	SignalBus.flower_gone_to_seed.connect(_on_flower_gone_to_seed)
	SignalBus.bee_arrived.connect(_on_bee_arrived)
	SignalBus.plant_died.connect(_on_plant_died)
	SignalBus.cut_flower_decayed.connect(_failure_check)
	cache.packet_printed.connect(_on_packet_printed)
	visitor_manager.visitor_left.connect(_on_visitor_left)
	player.energy_halved.connect(_on_energy_halved)
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
		if not cut_flower.is_decaying:
			return
	failure_screen.open()

func _on_visitor_left():
	if visitor_manager.done:
		completed_screen.open()
	else:
		_failure_check()

func _on_flower_bloomed(color):
	colors_grown[color] = true
	if in_tutorial and not genes_explained and color != Colors.yellow:
		genes_explained = true
		await get_tree().create_timer(BRIEF_PAUSE).timeout
		dialogue.punnet_square.visible = true
		dialogue.extra_space = 50
		dialogue.open([
			"That's a new color of sunflower! Yellow sunflowers are",
			"heterozygous, meaning they have two different types of color",
			"gene called Y and y.", "The table below shows the possibilities",
			"from crossing two Yy sunflowers.",
		])

func _on_flower_gone_to_seed():
	if in_tutorial and not seeds_explained:
		seeds_explained = true
		await get_tree().create_timer(BRIEF_PAUSE).timeout
		dialogue.open([
			"That sunflower has gone to seed. Interact with it while holding",
			"a seed bag to harvest the next generation of sunflower seeds!",
			"If you'd like a new seed bag to stay organized, come",
			"interact with the cache",
		])

func _on_bee_arrived():
	if in_tutorial and not bees_explained:
		bees_explained = true
		await get_tree().create_timer(BRIEF_PAUSE).timeout
		dialogue.open([
			"See those bees buzzing around that flower? When a flower fills",
			"up with nectar it attracts bees who will eventually pollinate it.",
			"They'll leave if you drink the nectar first, but if the flowers",
			"are becoming inbred and producing fewer seeds you might want to",
			"let them bee.",
		])

func _on_plant_died():
	_failure_check()
	if in_tutorial and not death_explained:
		death_explained = true
		await get_tree().create_timer(BRIEF_PAUSE).timeout
		dialogue.open([
			"When a plant has its last flower removed it will die. Make sure",
			"you harvest enough seeds to plant the next generation!",
		])

func _on_energy_halved():
	if in_tutorial and not energy_explained:
		energy_explained = true
		dialogue.open([
			"Careful, half your energy is gone. If it runs out you won't be",
			"able to carry items! Drinking nectar is the best way to restore",
			"energy, but perching can also restore a little if you're very low.",
		])

func _on_packet_printed():
	if in_tutorial and not packets_explained:
		packets_explained = true
		dialogue.open([
			"Multiple packets can help you organize seeds, although the",
			"paper will run if you print too many. You can transfer",
			"seeds from a packet you are holding into another packet by",
			"interacting with it.",
		])

func generate_starting_packet():
	var packet = seed_packet_scene.instantiate()
	packet.global_position = Vector2(-100,-100)
	add_sibling(packet)
	packet.item_sprite.modulate = Colors.yellow
	
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild("Sunflower"))

	starting_seeds[0]["max_flowers"] = 0
	starting_seeds[1]["max_flowers"] = 0
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[3]["max_flowers"] = 1

	starting_seeds.shuffle()
	packet.add_seeds(starting_seeds)
	return packet

func main():
	var g = {"species": "Sunflower", "yellow": 1}
	dialogue.punnet_square.fill(g, g)

	if skip_intro:
		await quick_intro_sequence()
	else:
		player.controllable = false
		await move_player_on_screen()
		await cache.raise()

		dialogue.open_yn([
			"Welcome to your first seed cache! I'm sure your elders already",
			"talked your feathers off about the journey, but would you like",
			"a reminder about how things work?",
		])
		var yes = await dialogue.yes_no
		if yes:
			in_tutorial = true
			await tutorial_sequence()
		else:
			await non_tutorial_sequence()

func move_player_on_screen():
	player.global_position = Vector2(-100,180)
	player.move_to_point(Vector2(140,180), true)
	await player.motion_finished

func quick_intro_sequence():
	cache.quick_raise()
	cache.quick_dispense_all(generate_starting_packet())
	player.global_position = Vector2(140,180)
	player.controllable = true
	
	await SignalBus.flower_bloomed
	visitor_manager.visitors_unlocked = true

func non_tutorial_sequence():
	dialogue.punnet_square.visible = true
	dialogue.open([
		"At this cache you'll be growing sunflowers!",
		"Sunflowers have one color gene with two alleles.",
	])
	player.controllable = true
	await cache.dispense_all(generate_starting_packet())

	await SignalBus.flower_bloomed
	visitor_manager.visitors_unlocked = true

func tutorial_sequence():
	dialogue.open([
		"First off, lets stretch your wings a bit. Move around with WASD",
		"or by clicking on a destination.",
	])
	player.controllable = true
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	await player.motion_finished
	await get_tree().create_timer(BRIEF_PAUSE).timeout

	dialogue.open([
		"Next, interaction. You can interact with things by clicking",
		"on them or by moving close to them and pressing E.",
		"Try perching on the sapling or bathing in the pond."
	])

	await player.bath_or_perch_started
	await get_tree().create_timer(1).timeout

	await cache.dispense_seeds(generate_starting_packet())
	dialogue.open([
		"This is a seed packet. You can pick up items",
		"by interacting with them while you aren't holding anything. You",
		"can drop items by right clicking or pressing Q."
	])

	await player.item_picked_up
	dialogue.open([
		"That seed packet contains four sunflower seeds. To plant one",
		"interact with a patch of bare soil while holding the packet.",
	])

	await player.seed_planted
	await cache.dispense_watering_can()
	
	if player.held_item is SeedPacket:
		dialogue.open([
			"Seeds need water to germinate, so you'll need this watering can.",
			"Drop the seed packet with Q or right click, then pick up the can",
			"and fly over the soil to water it. If the water runs out,",
			"interact with a body of water for a refill.",
		])
	else:
		dialogue.open([
			"Seeds need water to germinate, so you'll need this watering can.",
			"Pick it up and fly over the soil to water it. If the water runs",
			"out, interact with a body of water for a refill.",
		])

	await SignalBus.seedling_grown
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"Ah. The first of many seedlings you will help grow on this journey.",
		"You can just wait for it to bloom now, but plants in moist soil will",
		"grow and produce nectar more quickly."
	])

	await SignalBus.flower_bloomed
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"Aren't sunflowers beautiful? And their nectar is delicous too, or so",
		"I've heard. Interact with a flower to drink some!"
	])

	await player.drink_finished
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"See that yellow spot on your beak? That's pollen. If you drink from a",
		"flower with pollen on your beak you will pollinate it. A pollinated",
		"flower will stop blooming and start making seeds, so if you're not",
		"ready for that to happen make sure to take a bath!",
	])

	visitor_manager.visitors_unlocked = true
	await visitor_manager.visitor_arrived
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"A visitor has come to evaluate your flowercraft. You'll have to prove",
		"yourself to five visitors to earn the right to continue your journey.",
		"This one wants a yellow sunflower. Use these clippers to cut one.",
	])

	await cache.dispense_clippers()
	await SignalBus.flower_clipped
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"Now pick up the flower and bring it to the visitor to complete",
		"the request. Flowers left on the ground will rot, so don't cut too",
		"many at once!",
	])

	await visitor_manager.boquet_accepted
	await get_tree().create_timer(BRIEF_PAUSE).timeout
	dialogue.open([
		"Well done! You'll need to prove yourself to four more visitors to",
		"complete this cache challenge.",
	])

	var desired_bouquet_colors
	var colors_explained = false
	var multi_expliained = false
	while !(colors_explained and multi_expliained):
		desired_bouquet_colors = await visitor_manager.visitor_arrived
		await get_tree().create_timer(BRIEF_PAUSE).timeout
		
		if len(desired_bouquet_colors) == 2:
			multi_expliained = true
			dialogue.open([
				"This visitor is asking for two sunflowers. You can either",
				"deliver them one at a time or bring them both together.",
			])

		elif not colors_explained:
			colors_explained = true
			var color_name
			if desired_bouquet_colors[0] == Colors.white:
				color_name = "white"
			elif desired_bouquet_colors[0] == Colors.orange:
				color_name = "orange"
			else:
				assert(false)
			var s2
			if desired_bouquet_colors[0] not in colors_grown:
				s2 = "Try cross-pollinating yellow sunflowers and planting their seeds to grow one."
			else:
				s2 = "Make sure to bring visitors the colors they are asking for."
			dialogue.open([
				"This visitor is asking for a", color_name, "sunflower.",
				s2,
			])
