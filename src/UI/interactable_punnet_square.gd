extends Control



@onready var punnet_square = $PunnetContainer/PunnetSquare
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

@onready var species = get_tree().get_first_node_in_group("level").species

func _ready():
	for allele_option in [p1a1, p1a2, p1b1, p1b2, p1c1, p1c2, p2a1, p2a2, p2b1, p2b2, p2c1, p2c2]:
		allele_option.item_selected.connect(_on_allele_option_selected)

	if species == "Sunflower":
		for option in [p1a1, p1a2, p2a1, p2a2]:
			option.visible = true
			option.add_item("R")
			option.add_item("Y")
		p1a1.select(0)
		p1a2.select(0)
		p2a1.select(1)
		p2a2.select(1)
		_on_allele_option_selected(null)
	else:
		assert(false)

func _on_allele_option_selected(_selected):
	var g1 = {"species": species}
	var g2 = {"species": species}

	if species == "Sunflower":
		g1["color"] = 0
		g2["color"] = 0
		if p1a1.get_selected_id() == 0:
			g1["color"] += 1
		if p1a2.get_selected_id() == 0:
			g1["color"] += 1
		if p2a1.get_selected_id() == 0:
			g2["color"] += 1
		if p2a2.get_selected_id() == 0:
			g2["color"] += 1
	else:
		assert(false)

	p1_example_petals.modulate = GenomeHelpers.sunflower_flower_color(g1["color"])
	p2_example_petals.modulate = GenomeHelpers.sunflower_flower_color(g2["color"])
	punnet_square.fill(g1, g2)
