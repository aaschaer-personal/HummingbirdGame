extends SunflowerLevel

var level_num = 1

# colors, count, size, max_repetitions
var bouquet_recipes = [
		[[Colors.yellow], 1, 1, 1],
		[[Colors.orange], 1, 1, 1],
		["sunflower", 2, 2, 1],
		["sunflower", 1, 3, 1],
]

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild("sunflower"))
	starting_seeds[0]["max_flowers"] = 0
	starting_seeds[0]["color"] = ["Y", "Y"]
	starting_seeds[1]["max_flowers"] = 0
	starting_seeds[1]["color"] = ["Y", "Y"]
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[2]["color"] = ["Y", "Y"]
	starting_seeds[3]["max_flowers"] = 1
	starting_seeds[3]["color"] = ["R", "R"]
	return starting_seeds
