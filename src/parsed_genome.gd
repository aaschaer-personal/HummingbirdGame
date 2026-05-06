class_name ParsedGenome extends Node

var gene_dict: Dictionary
var species: String
var flower_color: Color
var max_concurrent_flowers: int
var max_flowers: int
var bloom_time: float
var seed_num: int
var growth_factor: float
var water_efficiency: float
var max_nectar: int

func set_vals_from_gene_dict(new_gene_dict):
	gene_dict = new_gene_dict
	species = gene_dict["species"]
	flower_color = GenomeHelpers.color_from_gene_dict(gene_dict)
	max_nectar = 30
	max_flowers = _parse_max_flowers()
	seed_num = _parse_inbreeding()
	growth_factor = 4
	water_efficiency = 1

func _parse_max_flowers():
	return 1 + gene_dict["max_flowers"][0] + gene_dict["max_flowers"][1]

func _parse_inbreeding():
	var inbreeding = gene_dict["inbreeding"]
	var most_copies = 1
	for allele in inbreeding:
		var count = inbreeding.count(allele)
		if count > most_copies:
			most_copies = count

	return 5 - most_copies

func _parse_growth_factor():
	var loci_1 = gene_dict["growth_facto_1"]
	var loci_2 = gene_dict["growth_facto_2"]
	return 2 + .5 * (loci_1 + loci_2)
