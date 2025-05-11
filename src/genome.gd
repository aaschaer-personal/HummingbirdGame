class_name Genome extends Node

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
	seed_num = _parse_unique_inbreeding_alleles()
	# TODO?
	# plants with high growth factor grow faster when kept watered, but use
	# up their water quickly
	# idealy all plants would grow equally quickly with one full water
	growth_factor = 4
	water_efficiency = 1

func _parse_max_flowers():
	var loci_1 = gene_dict["max_flowers"]
	return 1 + loci_1

func _parse_unique_inbreeding_alleles():
	var unique_alleles = []
	for allele in gene_dict["inbreeding"]:
		if allele not in unique_alleles:
			unique_alleles.append(allele)
	return unique_alleles.size()

func _parse_growth_factor():
	var loci_1 = gene_dict["growth_facto_1"]
	var loci_2 = gene_dict["growth_facto_2"]
	return 2 + .5 * (loci_1 + loci_2)
