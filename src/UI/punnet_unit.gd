extends Control

@onready var flower = $Flower
@onready var petals = $Petals
@onready var label = $Label

func fill(gene_dict):
	var level = get_tree().get_first_node_in_group("level")
	var flower_texture = level.flower_icon_texture
	var petals_texture = level.petals_icon_texture
	flower.texture = flower_texture
	petals.texture = petals_texture
	label.text = GenomeHelpers.code_from_gene_dict(gene_dict)
	petals.modulate = GenomeHelpers.color_from_gene_dict(gene_dict)
