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

	if species == "Sunflower":
		ret["color"] = 1
	elif species == "Lupine":
		ret["red"] = 1
		ret["blue"] = 1
	else:
		assert(false)

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
		"max_flowers",
		"growth_factor_1",
		"growth_factor_2",
	]
	if species == "Sunflower":
		ret.append("color")
	elif species == "Lupine":
		ret.append_array(["red", "blue"])
	else:
		assert(false)
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
	
func sunflower_flower_color(color):
	if color == 2:
		return Colors.red
	elif color == 1:
		return Colors.orange
	elif color == 0:
		return Colors.yellow
	else:
		assert(false)

func lupine_flower_color(red, blue):
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
