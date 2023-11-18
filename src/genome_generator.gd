# autoloaded as GenomeGenerator
extends Node

func wild(species):
	var ret = {
		"species": species
	}
	for key in _standard_keys_by_species(species):
		# 25% chance of 0, 50% chance of 1, 25% chance of 2
		ret[key] = randi() % 2 + randi() % 2

	# pick 4 unique inbreeding alleles
	ret["inbreeding"] = []
	while (ret["inbreeding"].size() < 4):
		var allele = randi() % 100
		if allele not in ret["inbreeding"]:
			ret["inbreeding"].append(allele)

	if species == "Lupine":
		ret["red"] = 1
		ret["blue"] = 1
	return ret

func starting_genome():
	var ret = wild("Lupine")
	return ret

func _pick_copy(dominant_count):
	if dominant_count == 2:
		return 1
	elif dominant_count == 0:
		return 0
	else:
		return randi() % 2

func _standard_keys_by_species(species):
	var ret = [
		"max_total_flowers",
		"seed_num_1",
		"seed_num_2",
		"growth_threshold_1",
		"growth_threshold_2",
	]
	if species == "Lupine":
		ret.append_array(["red", "blue"])
	return ret

func gamete_dict_from_genome_dict(genome_dict):
	var species = genome_dict["species"]
	var ret = {
		"species": species,
	}
	for key in _standard_keys_by_species(species):
		ret[key] = _pick_copy(genome_dict[key])
	ret["inbreeding"] = []
	ret["inbreeding"].append(genome_dict["inbreeding"][randi() % 2])
	ret["inbreeding"].append(genome_dict["inbreeding"][2 + randi() % 2])
	return ret

func genome_dict_from_gamete_dicts(gamete_1, gamete_2):
	var species = gamete_1["species"]
	if gamete_2["species"] != species:
		return null
	var ret = {
		"species": species,
	}
	for key in _standard_keys_by_species(species):
		ret[key] = gamete_1[key] + gamete_2[key]
	ret["inbreeding"] = gamete_1["inbreeding"] + gamete_2["inbreeding"]
	return ret
