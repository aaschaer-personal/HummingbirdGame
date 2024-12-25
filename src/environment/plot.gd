class_name Plot extends Interactable

@onready var dirt_sprite = $Dirt
var plant = null
var wetness = 0
var plant_scene = null

func _process(delta):
	wetness -= 1 * delta
	if wetness < 0:
		wetness = 0
	var shade = 60 / (wetness + 60)
	dirt_sprite.modulate = Color(shade, shade, shade)

func is_interactable():
	return player.held_item is SeedPacket

func get_player_interaction():
	return "use_tool_on_plot"

func plant_seed(gene_dict):
	if gene_dict != null:
		if plant_scene == null:
			var species = gene_dict["species"].to_lower()
			print(species)
			plant_scene = load("res://src/flowers/%s/%s_plant.tscn" % [species,species])
		var new_plant = plant_scene.instantiate()
		add_child(new_plant)
		new_plant.genome.set_vals_from_gene_dict(gene_dict)
		plant = new_plant

func remove_seed():
	if plant.stage == 0:		
		var seed_genome = plant.genome.gene_dict
		plant.queue_free()
		plant = null
		return seed_genome

func water(delta):
	await get_tree().create_timer(0.5).timeout
	wetness += delta * 80
	if wetness >= 40:
		wetness = 40

func dry(amount):
	wetness -= amount
