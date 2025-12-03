extends HibiscusLevel

var level_num = 5

# colors, count, size, max_repetitions
var easy_colors = [Colors.red, Colors.yellow, Colors.purple, Colors.white]
var hard_colors = [Colors.pink, Colors.orange, Colors.blue]

var bouquet_recipes = [
	[[Colors.red, Colors.yellow, Colors.white], 1, 2, 1],
	[easy_colors, 3, 3, 2],
	[[easy_colors, easy_colors, hard_colors], 3, 3, 1],
	["hibiscus", 4, 4, 3],
	[[hard_colors, hard_colors, easy_colors, easy_colors, easy_colors], 3, 5, 2],
	[[Colors.red, Colors.pink, Colors.orange, Colors.blue, [Colors.yellow, Colors.white]], 1, 5, 1],
]

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(3):
		starting_seeds.append(GenomeGenerator.wild("hibiscus"))
	starting_seeds[0]["max_flowers"] = 1
	starting_seeds[0]["red"] = ["R", "R"]
	starting_seeds[0]["other"] = ["B", "B"]
	starting_seeds[1]["max_flowers"] = 1
	starting_seeds[1]["red"] = ["r", "r"]
	starting_seeds[1]["other"] = ["Y", "Y"]
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[2]["red"] = ["r", "r"]
	starting_seeds[2]["other"] = ["w", "w"]
	return starting_seeds
