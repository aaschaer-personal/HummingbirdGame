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
		var sapling = $Sapling
		sapling.set_arrow_side_visibility(true)
		await player.energy_to_third_or_perch
		sapling.set_arrow_side_visibility(false)
		await player.energy_back_to_half
		await remove_tutorial_text("Energy")

func _on_watering_can_emptied():
	if not water_explained:
		water_explained = true
		add_tutorial_text("Water",
		"""Refill the watering can:

Interact with the pond (left click or %interact) while holding the watering can.

""")
	var pond = $Pond
	pond.set_arrow_side_visibility(true)
	await SignalBus.watering_can_refilled
	pond.set_arrow_side_visibility(false)
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
"""Open the guide to read controls:

1. Press %pause to open the pause menu.
2. Click on Guide.
3. Read the controls.
4. Close with %exit_menu.
5. Reference back as needed!

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
5. Water seeds (move while holding the watering can).
6. Drop the watering can (right click or %drop).
7. Wait for the flowers to grow and bloom.

""")
		while flowers_grown < 6:
			var seeds_planted = 0
			var seeds_watered = 0
			var watering_can = get_tree().get_first_node_in_group("watering_can")
			for plot in get_tree().get_nodes_in_group("plot"):
				if plot.plant:
					seeds_planted += 1
					if plot.wetness > 10 or plot.plant.stage > 0:
						seeds_watered += 1

			if seeds_planted < 4:
				watering_can.set_arrow_main_visibility(false)
				# arrow over starting packet if not held
				if player.held_item != starting_packet:
					starting_packet.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up
					if player.held_item == starting_packet:
						starting_packet.set_arrow_main_visibility(false)
					continue
				# arrow over empty plots
				else:
					for plot in get_tree().get_nodes_in_group("plot"):
						if not plot.plant:
							plot.set_arrow_main_visibility(true)
					await SignalBus.seed_planted_removed_or_item_dropped
					for plot in get_tree().get_nodes_in_group("plot"):
						if plot.plant or player.held_item != starting_packet:
							plot.set_arrow_main_visibility(false)
					continue
			elif seeds_watered < 4:
				for plot in get_tree().get_nodes_in_group("plot"):
					if not plot.plant:
						plot.set_arrow_main_visibility(false)
				# arrow over watering can if not held
				if player.held_item != watering_can:
					watering_can.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up_or_seed_removed
					if player.held_item == watering_can:
						watering_can.set_arrow_main_visibility(false)
					continue
				# arrow over plots until watered
				else:
					for plot in get_tree().get_nodes_in_group("plot"):
						if plot.plant and (plot.wetness < 10 and plot.plant.stage == 0):
							plot.set_arrow_main_visibility(true)
					await SignalBus.plot_watered_seed_removed_or_item_dropped
					for plot in get_tree().get_nodes_in_group("plot"):
						if player.held_item != watering_can:
							plot.set_arrow_main_visibility(false)
						elif plot.plant and (plot.wetness > 10 or plot.plant.stage > 0):
							plot.set_arrow_main_visibility(false)
			# wait for blooms
			else:
				await get_tree().create_timer(0.1, false).timeout

		await remove_tutorial_text("GrowFlowers")
	if not flower_accepted:
		add_tutorial_text("SatisfyVisitor",
"""Satisfy a visitor:

1. Pick up clippers (left click or %interact)
2. Cut a yellow flower (left click or %interact while holding the clippers).
4. Drop the clippers (right click or %drop)
3. Pick up the cut flower (left click or %interact).
3. Deliver the flower to the vistitor (left click %interact while holding a flower).

""")
		while not flower_accepted:
			var clippers = get_tree().get_first_node_in_group("clippers")
			var cut_yellow_flower = get_tree().get_first_node_in_group("cut_yellow_flowers")
			if not cut_yellow_flower or cut_yellow_flower.is_decaying:
				# arrow over clippers if no flower cut and player not holding them
				if player.held_item != clippers:
					clippers.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up
					if player.held_item == clippers:
						clippers.set_arrow_main_visibility(false)
					continue
				# arrow over flower if no flower cut and player holding clippers
				else:
					for flower in get_tree().get_nodes_in_group("yellow_flowers"):
						flower.set_arrow_main_visibility(true)
					await SignalBus.flower_cut_or_item_dropped
					for flower in get_tree().get_nodes_in_group("yellow_flowers"):
						flower.set_arrow_main_visibility(false)
					continue
			else:
				clippers.set_arrow_main_visibility(false)
				# arrow over cut flower if player not holding it
				var holding_yellow_flower = false
				if player.held_item is Bouquet:
					for flower in player.held_item.get_flowers():
						if flower.color == Colors.yellow:
							holding_yellow_flower = true
							break
				if not holding_yellow_flower:
					cut_yellow_flower.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up_or_flower_decayed
					if player.held_item is Bouquet:
						for flower in player.held_item.get_flowers():
							if flower.color == Colors.yellow:
								holding_yellow_flower = true
								break
					if holding_yellow_flower or cut_yellow_flower.is_decaying:
						cut_yellow_flower.set_arrow_main_visibility(false)
					continue
				# arrow over visitor if player holding cut flower
				else:
					var visitor = get_tree().get_first_node_in_group("visitors")
					visitor.set_arrow_main_visibility(true)
					await SignalBus.flower_accepted_or_item_dropped
					visitor.set_arrow_main_visibility(false)
					# brief wait to make sure level.flower_accepted is updated
					await get_tree().create_timer(0.1, false).timeout
					continue
		if not visitor_left:
			await visitor_manager.visitor_left
		await remove_tutorial_text("SatisfyVisitor")

	if Colors.orange not in colors_pollinated:
		add_tutorial_text("OrangePollination",
"""Cross-pollinate for an orange sunflower:

1. If there is any pollen on your beak, take a bath in the pond (left click or %interact).
2. Drink from a sunflower to get its pollen on your beak (left click or %interact).
3. Drink from the other color sunflower to pollinate it (left click or %interact).
4. Wait for the pollinated sunflower to go to seed.

""")
		# if player has pollen, arrow over pond until bathed
		if player.pollen:
			var pond = $Pond
			pond.set_arrow_main_visibility(true)
			await player.bath_started
			pond.set_arrow_main_visibility(false)
			await player.drink_or_bath

		# arrow over flowers that the player doesn't have pollen for
		while Colors.orange not in colors_pollinated:
			var red_drink = false
			var yellow_drink = false
			for gene_dict in player.pollen:
				var color = GenomeHelpers.color_from_gene_dict(gene_dict)
				if color == Colors.red:
					red_drink = true
				elif color == Colors.yellow:
					yellow_drink = true

			if not red_drink:
				for flower in get_tree().get_nodes_in_group("red_flowers"):
					flower.set_arrow_main_visibility(true)
			if not yellow_drink:
				for flower in get_tree().get_nodes_in_group("yellow_flowers"):
					flower.set_arrow_main_visibility(true)
			if yellow_drink and red_drink:
					break

			await player.drink_or_bath
			if player.drinking_flower:
				if player.drinking_flower.color == Colors.red:
					red_drink = true
					for flower in get_tree().get_nodes_in_group("red_flowers"):
						flower.set_arrow_main_visibility(false)
				elif player.drinking_flower.color == Colors.yellow:
					yellow_drink = true
					for flower in get_tree().get_nodes_in_group("yellow_flowers"):
						flower.set_arrow_main_visibility(false)
				if yellow_drink and red_drink:
					break

		for flower in get_tree().get_nodes_in_group("red_flowers"):
			flower.set_arrow_main_visibility(false)
		for flower in get_tree().get_nodes_in_group("yellow_flowers"):
			flower.set_arrow_main_visibility(false)

		while Colors.orange not in colors_pollinated:
			await SignalBus.flower_pollinated
		await remove_tutorial_text("OrangePollination")

	if not packet_printed:
		add_tutorial_text("PrintPacket",
"""Print a new seed packet:

1. Open the cache menu (left click or %interact).
2. Select a color, icon, and/or icon color.
3. Press print.

""")
		# arrow over cache until used
		cache.set_arrow_main_visibility(true)
		await cache.print_started
		cache.set_arrow_main_visibility(false)
		await cache.packet_printed
		await remove_tutorial_text("PrintPacket")

	if not orange_seeds_harvested:
		add_tutorial_text("HarvestSeeds",
"""Harvest orange sunflower seeds:

1. Pick up the new seed packet (left click or %interact).
2. Harvest seeds from the flower gone to seed (left click or %interact while holding a seed packet).

""")
		while not orange_seeds_harvested:
			# arrow on new seed packet until a seed packet is picked up
			if not player.held_item is SeedPacket:
				var new_seed_packet
				for seed_packet in get_tree().get_nodes_in_group("seed_packets"):
					if seed_packet != starting_packet:
						new_seed_packet = seed_packet
						break
				new_seed_packet.set_arrow_main_visibility(true)
				await SignalBus.item_picked_up
				if player.held_item is SeedPacket:
					new_seed_packet.set_arrow_main_visibility(false)
				continue
			else:
				# arrow on orange seeds until they are harvested or cut
				var orange_seeds = get_tree().get_first_node_in_group("orange_seeds")
				if orange_seeds:
					orange_seeds.set_arrow_main_visibility(true)
					await SignalBus.orange_seeds_harvested_or_flower_cut
					# brief wait to make sure level.orange_seeds_harvested is updated
					await get_tree().create_timer(0.1, false).timeout
		for seed_packet in get_tree().get_nodes_in_group("seed_packets"):
			seed_packet.set_arrow_main_visibility(false)
		await remove_tutorial_text("HarvestSeeds")

	if not Colors.orange in colors_grown:
		add_tutorial_text("OrangeGrow",
"""Grow an orange sunflower:

1. Plant one of the cross-pollinated seeds.
2. Water and wait for the flower to grow and bloom.

""")
		while not Colors.orange in colors_grown:
			var orange_seeds_planted = 0
			var orange_seeds_watered = 0
			var watering_can = get_tree().get_first_node_in_group("watering_can")
			for plot in get_tree().get_nodes_in_group("plot"):
				if plot.plant and plot.plant.genome.flower_color == Colors.orange:
					orange_seeds_planted += 1
					if plot.wetness > 10 or plot.plant.stage > 0:
						orange_seeds_watered += 1

			if orange_seeds_planted < 1:
				watering_can.set_arrow_main_visibility(false)
				# arrow over orange packet if not held
				var orange_packet
				for seed_packet in get_tree().get_nodes_in_group("seed_packets"):
					for genome_dict in seed_packet.seeds:
						if GenomeHelpers.color_from_gene_dict(genome_dict) == Colors.orange:
							orange_packet = seed_packet
							break
				if player.held_item != orange_packet:
					orange_packet.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up
					if player.held_item == orange_packet:
						orange_packet.set_arrow_main_visibility(false)
					continue
				# arrow over empty plots
				else:
					for plot in get_tree().get_nodes_in_group("plot"):
						if not plot.plant:
							plot.set_arrow_main_visibility(true)
					await SignalBus.seed_planted_removed_or_item_dropped
					for plot in get_tree().get_nodes_in_group("plot"):
						if plot.plant or not player.held_item is SeedPacket:
							plot.set_arrow_main_visibility(false)
					continue

			elif orange_seeds_watered < 1:
				for plot in get_tree().get_nodes_in_group("plot"):
					if not plot.plant:
						plot.set_arrow_main_visibility(false)
				for seed_packet in get_tree().get_nodes_in_group("seed_packets"):
					seed_packet.set_arrow_main_visibility(false)
				# arrow over watering can if not held
				if player.held_item != watering_can:
					watering_can.set_arrow_main_visibility(true)
					await SignalBus.item_picked_up_or_seed_removed
					if player.held_item == watering_can:
						watering_can.set_arrow_main_visibility(false)
					continue
				# arrow over orange seed until watered
				else:
					for plot in get_tree().get_nodes_in_group("plot"):
						if plot.plant and plot.plant.genome.flower_color == Colors.orange and (plot.wetness < 10 and plot.plant.stage == 0):
							plot.set_arrow_main_visibility(true)
					await SignalBus.plot_watered_seed_removed_or_item_dropped
					for plot in get_tree().get_nodes_in_group("plot"):
						if player.held_item != watering_can:
							plot.set_arrow_main_visibility(false)
						elif plot.plant and (plot.wetness > 10 or plot.plant.stage > 0):
							plot.set_arrow_main_visibility(false)
			# wait for bloom
			else:
				for plot in get_tree().get_nodes_in_group("plot"):
					plot.set_arrow_main_visibility(false)
				await get_tree().create_timer(0.1, false).timeout
		await remove_tutorial_text("OrangeGrow")

	add_tutorial_text("FinishLevel",
"""Finish the level:

Satisfy all five visitors to finish the level.

""")

func set_tutorial_visibility(toggle_value):
	tutorial_container.visible = toggle_value
