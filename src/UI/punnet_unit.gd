extends Control

@onready var flower = $Flower
@onready var petals = $Petals
@onready var gene_label = $GeneLabel
@onready var color_label = $ColorLabel
@onready var options = get_tree().get_first_node_in_group("options")

var flower_texture = null
var petals_texture = null

func _ready():
	options.label_colors_changed.connect(set_color_label_visibility)
	set_color_label_visibility(Config.get_option("label_colors"))

func set_color_label_visibility(toggle_value):
	color_label.visible = toggle_value
	petals.visible = not toggle_value
	flower.visible = not toggle_value

func load_textures_if_needed(species):
	if not flower_texture:
		flower_texture = load("res://assets/UI/Icons/%s.png" % species)
		petals_texture = load("res://assets/UI/Icons/%s_petals.png" % species)

func fill(gene_dict):
	var species = gene_dict["species"]
	load_textures_if_needed(species)
	flower.texture = flower_texture
	petals.texture = petals_texture
	gene_label.text = GenomeHelpers.code_from_gene_dict(gene_dict)
	var color = GenomeHelpers.color_from_gene_dict(gene_dict)
	petals.modulate = color
	color_label.text = Colors.color_name(color)
