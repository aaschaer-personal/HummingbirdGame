# autoloaded as GenomeGenerator
extends Node

var next_gene_storage: Dictionary = {}
var inbreeding_counter = 0

var color_keys_by_species = {
	"sunflower": ["color"],
	"jewelweed": ["color"],
	"lupine": ["red", "blue"],
	"zinnia": ["color"],
	"hibiscus": ["red", "other"],
	"orchid": ["red", "yellow", "blue"],
}

func get_next_inbreeding():
	var ret = [inbreeding_counter, inbreeding_counter + 1]
	inbreeding_counter += 2
	return ret

func wild_gene_dict(species: String) -> Dictionary:
	var ret = {
		"species": species
	}
	ret["max_flowers"] = [1, 1]
	ret["inbreeding"] = get_next_inbreeding()

	if species == "sunflower":
		ret["color"] = ["R", "Y"]

	elif species == "jewelweed":
		var options = ["R", "Y", "P"]
		var a1 = options[randi() % len(options)]
		var a2 = options[randi() % len(options)]
		while a1 == a2:
			a2 = options[randi() % len(options)]
		ret["color"] = [a1, a2]

	elif species == "lupine":
		ret["red"] = ["R", "r"]
		ret["blue"] = ["B", "b"]

	elif species == "zinnia":
		var options = ["R", "Y", "F", "w"]
		var a1 = options[randi() % len(options)]
		var a2 = options[randi() % len(options)]
		while a1 == a2:
			a2 = options[randi() % len(options)]
		ret["color"] = [a1, a2]

	elif species == "hibiscus":
		ret["red"] = ["R", "r"]
		var options = ["B", "Y", "w"]
		var a1 = options[randi() % len(options)]
		var a2 = options[randi() % len(options)]
		while a1 == a2:
			a2 = options[randi() % len(options)]
		ret["other"] = [a1, a2]

	elif species == "orchid":
		ret["red"] = ["R", "r"]
		ret["yellow"] = ["Y", "y"]
		ret["blue"] = ["B", "b"]

	else:
		assert(false)

	return ret

func initialize_next_gene_storage(species: String):
	next_gene_storage = {"max_flowers": {}}
	for color_key in color_keys_by_species[species]:
		next_gene_storage[color_key] = {}

func _get_offspring_gene(gene, p1, p2):
	var pa = [p1[gene], p2[gene]]
	pa.sort()
	var key = str(pa)
	if key not in next_gene_storage[gene].keys() or next_gene_storage[gene][key] == []:
		next_gene_storage[gene][key] = [
			[pa[0][0], pa[1][0]],
			[pa[0][0], pa[1][1]],
			[pa[0][1], pa[1][0]],
			[pa[0][1], pa[1][1]],
		]
		next_gene_storage[gene][key].shuffle()
	return next_gene_storage[gene][key].pop_back()

func offspring_from_parent_genome_dicts(p1: Dictionary, p2: Dictionary):
	var species = p1["species"]
	var offspring = {"species": species}
	var keys = ["max_flowers"] + color_keys_by_species[species]
	for key in keys:
		offspring[key] = _get_offspring_gene(key, p1, p2)

	var p1i = p1["inbreeding"].duplicate()
	var p2i = p2["inbreeding"].duplicate()
	for i in [p1i, p2i]:
		if len(i) > 2:
			i.shuffle()
			i.resize(2)
	offspring["inbreeding"] = p1i + p2i
	return offspring
