extends SunflowerLevel

func _ready():
	level_num = 1
	level_intro_text = """Welcome to the Sunflower cache, the first cache of the Journey!
Here, we teach the basics of growing and crossing flowers."""
	# colors, count, size, max_repetitions
	bouquet_recipes = [
		[[Colors.yellow], 1, 1, 1],
		[[Colors.orange], 1, 1, 1],
		["sunflower", 2, 2, 1],
		["sunflower", 1, 3, 1],
]
	super()

	SignalBus.watering_can_emptied.connect(_on_watering_can_emptied)
	player.energy_quartered.connect(_on_energy_quartered)
	var options = get_tree().get_first_node_in_group("options")
	options.show_tutorial_changed.connect(set_tutorial_visibility)

func main():
	await super()
	set_tutorial_visibility(Config.get_option("show_tutorial"))
	tutorial_sequence()

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild_gene_dict("sunflower"))
	starting_seeds[0]["max_flowers"] = [0, 0]
	starting_seeds[0]["color"] = ["Y", "Y"]
	starting_seeds[1]["max_flowers"] = [0, 0]
	starting_seeds[1]["color"] = ["Y", "Y"]
	starting_seeds[2]["max_flowers"] = [1, 0]
	starting_seeds[2]["color"] = ["Y", "Y"]
	starting_seeds[3]["max_flowers"] = [1, 0]
	starting_seeds[3]["color"] = ["R", "R"]
	return starting_seeds

# Tutorial logic

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

1. Pick up a seed packet (left click or %interact).
2. Plant seeds in bare soil (left click or %interact while holding a seed packet).
3. Drop the seed packet (right click or %drop).
4. Pick up the watering can (left click or %interact).
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

1. If there is any pollen on your beak, take a bath in the pond (left click or %interact).
2. Drink from a red or yellow sunflower (left click or %interact).
3. Drink from the other collor sunflower (left click or %interact).

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
