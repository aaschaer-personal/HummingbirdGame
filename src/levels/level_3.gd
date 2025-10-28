extends LupineLevel

var level_num = 3

# colors, count, size, max_repetitions
var bouquet_recipes = [
	[[Colors.purple, [Colors.blue, Colors.pink]], 2, 2, 1],
	[[Colors.red, Colors.white], 1, 1, 1],
	[[Colors.purple, Colors.blue, Colors.pink], 1, 3, 2],
	[[Colors.red, Colors.white], 1, 2, 1],
	["lupine", 3, 3, 2],
	["lupine", 3, 4, 3],
	["lupine", 1, 5, 1],
]

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild("lupine"))
	starting_seeds[0]["max_flowers"] = 0
	starting_seeds[1]["max_flowers"] = 1
	starting_seeds[2]["red"] = ["r", "r"]
	starting_seeds[2]["blue"] = ["B", "B"]
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[3]["red"] = ["R", "r"]
	starting_seeds[3]["blue"] = ["b", "b"]
	starting_seeds[3]["max_flowers"] = 1
	return starting_seeds
