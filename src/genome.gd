class_name Genome extends Node

var genome_dict: Dictionary
var species: String
var flower_color: Color
var max_concurrent_flowers: int
var max_total_flowers: int
var bloom_time: float
var seed_num: int
var growth_threshold: float
var water_efficiency: float
var max_nectar: int

func set_vals_from_genome_dict(new_genome_dict):
	genome_dict = new_genome_dict
	species = genome_dict["species"]
	if species == "Lupine":
		flower_color = _parse_lupine_flower_color()
		max_nectar = 30
	max_total_flowers = _parse_max_total_flowers()
	seed_num = _parse_unique_inbreeding_alleles()
	# DEBUG FIXME
	# growth_threshold = _parse_growth_threshold()
	# water_efficiency = 3.0 / growth_threshold
	growth_threshold = 1
	water_efficiency = 1

func _parse_max_total_flowers():
	var loci_1 = genome_dict["max_total_flowers"]
	return 1 + loci_1

func _parse_unique_inbreeding_alleles():
	var unique_alleles = []
	for allele in genome_dict["inbreeding"]:
		if allele not in unique_alleles:
			unique_alleles.append(allele)
	return unique_alleles.size()

func _parse_growth_threshold():
	var loci_1 = genome_dict["growth_threshold_1"]
	var loci_2 = genome_dict["growth_threshold_2"]
	return 2 + .5 * (loci_1 + loci_2)

func _parse_lupine_flower_color():
	var red = genome_dict["red"]
	var blue = genome_dict["blue"]
	if red == 2:
		if blue == 0:
			return Color.DARK_RED
		else:
			return Color.BLUE_VIOLET
	if red == 1:
		if blue == 0:
			return Color.LIGHT_PINK
		else:
			return Color.BLUE_VIOLET
	if red == 0:
		if blue == 0:
			return Color.WHITE
		else:
			return Color.MEDIUM_BLUE
