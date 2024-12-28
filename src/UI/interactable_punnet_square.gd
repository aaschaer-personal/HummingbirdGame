extends Control

@onready var punnet_square = $PunnetContainer/PunnetSquare
@onready var p1_example_flower = $P1/Example/Flower
@onready var p2_example_flower = $P2/Example/Flower
@onready var p1_example_petals = $P1/Example/Petals
@onready var p2_example_petals = $P2/Example/Petals
@onready var p1a1 = $P1/A1
@onready var p1a2 = $P1/A2
@onready var p1b1 = $P1/B1
@onready var p1b2 = $P1/B2
@onready var p1c1 = $P1/C1
@onready var p1c2 = $P1/C2
@onready var p2a1 = $P2/A1
@onready var p2a2 = $P2/A2
@onready var p2b1 = $P2/B1
@onready var p2b2 = $P2/B2
@onready var p2c1 = $P2/C1
@onready var p2c2 = $P2/C2

var species

func _ready():
	var level = get_tree().get_first_node_in_group("level")
	if level:
		species = level.flower_species
		var flower_texture = load("res://assets/UI/Icons/%s.png" % species.to_lower())
		p1_example_flower.texture = flower_texture
		p2_example_flower.texture = flower_texture
		var petals_texture = load("res://assets/UI/Icons/%s_petals.png" % species.to_lower())
		p1_example_petals.texture = petals_texture
		p2_example_petals.texture = petals_texture
	
	for allele_option in [p1a1, p1a2, p1b1, p1b2, p1c1, p1c2, p2a1, p2a2, p2b1, p2b2, p2c1, p2c2]:
		allele_option.item_selected.connect(_on_allele_option_selected)

	if species == "sunflower":
		for option in [p1a1, p1a2, p2a1, p2a2]:
			option.visible = true
			option.add_item("R")
			option.add_item("Y")
		p1a1.select(0)
		p1a2.select(0)
		p2a1.select(1)
		p2a2.select(1)
		_on_allele_option_selected(null)
	elif species == "jewelweed":
		for option in [p1a1, p1a2, p2a1, p2a2]:
			option.visible = true
			option.add_item("R")
			option.add_item("P")
			option.add_item("Y")
		p1a1.select(0)
		p1a2.select(1)
		p2a1.select(1)
		p2a2.select(2)
		_on_allele_option_selected(null)
	else:
		assert(level == null)

func _on_allele_option_selected(_selected):
	var g1 = {"species": species}
	var g2 = {"species": species}

	if species == "sunflower":
		var map = {
			0: "R",
			1: "Y",
		}
		g1["color"] = [map[p1a1.get_selected_id()], map[p1a2.get_selected_id()]]
		g2["color"] = [map[p2a1.get_selected_id()], map[p2a2.get_selected_id()]]
	elif species == "jewelweed":
		var map = {
			0: "R",
			1: "P",
			2: "Y",
		}
		g1["color"] = [map[p1a1.get_selected_id()], map[p1a2.get_selected_id()]]
		g2["color"] = [map[p2a1.get_selected_id()], map[p2a2.get_selected_id()]]
	else:
		assert(false)

	p1_example_petals.modulate = GenomeHelpers.color_from_gene_dict(g1)
	p2_example_petals.modulate = GenomeHelpers.color_from_gene_dict(g2)
	punnet_square.fill(g1, g2)
