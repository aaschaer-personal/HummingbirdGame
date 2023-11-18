class_name Plot extends Interactable

@onready var plot_sprite = $PlotSprite
@onready var dry_texture =  preload("res://assets/Tiles/dirt.png")
@onready var wet_texture =  preload("res://assets/Tiles/wet_dirt.png")
@onready var lupine_plant_scene = preload("res://src/flowers/lupine_plant.tscn")
var plant = null
var wetness = 0

func _process(delta):
	wetness -= 1 * delta
	if wetness < 0:
		wetness = 0
	var shade = 60 / (wetness + 60)
	plot_sprite.modulate = Color(shade, shade, shade)

func is_interactable():
	return player.held_item is SeedBag

func on_clicked(_point: Vector2):
	if is_interactable():
		player.set_interaction_target(
			"use_tool_on_plot",
			self,
			player.general_interaction_area,
			self,
			global_position
		)

func plant_seed(genome_dict):
	if genome_dict != null:
		var new_plant = lupine_plant_scene.instantiate()
		add_child(new_plant)
		new_plant.genome.set_vals_from_genome_dict(genome_dict)
		plant = new_plant

func remove_seed():
	if plant.stage == 0:		
		var seed_genome = plant.genome.genome_dict
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
