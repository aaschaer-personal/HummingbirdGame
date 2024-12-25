# autoloaded as GenomeGenerator
extends Node

var int_keys = [
	"max_flowers",
	"growth_factor_1",
	"growth_factor_2",
]

var color_keys_by_species = {
	"Sunflower": ["color"],
	"Jewelweed": ["color"],
	"Lupine": ["red", "blue"],
}

func wild(species):
	var ret = {
		"species": species
	}
	for key in int_keys:
		# 25% chance of 0, 50% chance of 1, 25% chance of 2
		ret[key] = randi() % 2 + randi() % 2

	# pick 4 unique inbreeding alleles
	ret["inbreeding"] = []
	while (ret["inbreeding"].size() < 4):
		var allele = randi() % 100
		if allele not in ret["inbreeding"]:
			ret["inbreeding"].append(allele)

	if species == "Sunflower":
		ret["color"] = ["R", "Y"]
	elif species == "Jewelweed":
		var options = {
			0: ["R", "Y"],
			1: ["R", "P"],
			2: ["P", "Y"],
		}
		ret["color"] = options[randi() % 3]
	elif species == "Lupine":
		ret["red"] = ["R", "r"]
		ret["blue"] = ["B", "b"]
	else:
		assert(false)

	return ret

func _pick_int_copy(dominant_count):
	if dominant_count == 2:
		return 1
	elif dominant_count == 0:
		return 0
	else:
		return randi() % 2

func gamete_dict_from_gene_dict(gene_dict):
	var species = gene_dict["species"]
	var ret = {
		"species": species,
	}
	for key in int_keys:
		ret[key] = _pick_int_copy(gene_dict[key])
	for key in color_keys_by_species[species]:
		ret[key] = gene_dict[key][randi() % 2]
	ret["inbreeding"] = []
	ret["inbreeding"].append(gene_dict["inbreeding"][randi() % 2])
	ret["inbreeding"].append(gene_dict["inbreeding"][2 + randi() % 2])
	return ret

func gene_dict_from_gamete_dicts(gamete_1, gamete_2):
	var species = gamete_1["species"]
	if gamete_2["species"] != species:
		return null
	var ret = {
		"species": species,
	}
	for key in int_keys:
		ret[key] = gamete_1[key] + gamete_2[key]
	for key in color_keys_by_species[species]:
		ret[key] = [gamete_1[key], gamete_2[key]]
	ret["inbreeding"] = gamete_1["inbreeding"] + gamete_2["inbreeding"]
	return ret
