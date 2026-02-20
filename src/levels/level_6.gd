extends OrchidLevel

var level_num = 6

var easy_colors = [Colors.fushia, Colors.yellow, Colors.white]
var medium_colors = [Colors.orange, Colors.blue, Colors.purple]
var hard_colors = [Colors.red, Colors.pink, Colors.green]

# colors, count, size, max_repetitions
var bouquet_recipes = [
	[easy_colors, 2, 2, 2],
	[[easy_colors, easy_colors, medium_colors], 2, 3, 1],
	[[easy_colors, medium_colors, medium_colors], 1, 3, 1],
	[medium_colors, 1, 3, 1],
	[[easy_colors, easy_colors, hard_colors, hard_colors], 3, 4, 2],
	[[medium_colors, medium_colors, hard_colors, hard_colors], 3, 4, 2],
	[hard_colors, 1, 3, 1],
	["orchid", 1, 4, 1],
	["orchid", 3, 5, 2],
	[[medium_colors, medium_colors, hard_colors, hard_colors, hard_colors], 1, 5, 1],
]

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild("orchid"))
	starting_seeds[0]["red"] = ["R", "r"]
	starting_seeds[0]["blue"] = ["B", "b"]
	starting_seeds[0]["yellow"] = ["Y", "y"]
	starting_seeds[0]["max_flowers"] = 1

	starting_seeds[1]["red"] = ["r", "r"]
	starting_seeds[1]["blue"] = ["b", "b"]
	starting_seeds[1]["yellow"] = ["y", "y"]
	starting_seeds[1]["max_flowers"] = 1

	starting_seeds[2]["red"] = ["R", "R"]
	starting_seeds[2]["blue"] = ["B", "B"]
	starting_seeds[2]["yellow"] = ["y", "y"]
	starting_seeds[2]["max_flowers"] = 0

	starting_seeds[3]["red"] = ["r", "r"]
	starting_seeds[3]["blue"] = ["b", "b"]
	starting_seeds[3]["yellow"] = ["Y", "Y"]
	starting_seeds[3]["max_flowers"] = 1

	return starting_seeds
