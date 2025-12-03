extends JewelweedLevel

var level_num = 2

# colors, count, size, max_repetitions
var bouquet_recipes = [
	[[Colors.red, Colors.yellow], 1, 1, 1],
	[[Colors.orange, Colors.purple], 1, 1, 1],
	["jewelweed", 3, 2, 1],
	["jewelweed", 2, 3, 2],
	["jewelweed", 1, 4, 1],
]

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(3):
		starting_seeds.append(GenomeGenerator.wild("jewelweed"))
	starting_seeds[0]["max_flowers"] = 1
	starting_seeds[0]["color"] = ["R", "R"]
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[2]["color"] = ["Y", "Y"]
	starting_seeds[1]["max_flowers"] = 0
	starting_seeds[1]["color"] = ["P", "P"]
	return starting_seeds
