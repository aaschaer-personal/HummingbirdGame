extends Control

@onready var flower = $Flower
@onready var petals = $Petals
@onready var label = $Label

func fill(gene_dict):
	var species = gene_dict["species"].to_lower()
	var flower_texture = load("res://assets/UI/Icons/%s.png" % species)
	flower.texture = flower_texture
	var petals_texture = load("res://assets/UI/Icons/%s_petals.png" % species)
	petals.texture = petals_texture
	label.text = GenomeHelpers.code_from_gene_dict(gene_dict)
	petals.modulate = GenomeHelpers.color_from_gene_dict(gene_dict)
