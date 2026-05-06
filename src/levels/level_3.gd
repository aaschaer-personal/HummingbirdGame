extends LupineLevel


func _ready():
	level_num = 3
	level_intro_text = """Welcome to the Lupine cache!
Here you will have your first experience with multiple color genes. Each gene combines independently, so the possible outcomes of a cross have expanded significantly.

Your starting seeds' color genes are RrBb (2), Rrbb, and rrBB."""
	# colors, count, size, max_repetitions
	bouquet_recipes = [
		[[Colors.purple, [Colors.blue, Colors.pink]], 2, 2, 1],
		[[Colors.red, Colors.white], 1, 1, 1],
		[[Colors.purple, Colors.blue, Colors.pink], 1, 3, 2],
		[[Colors.red, Colors.white], 1, 2, 1],
		["lupine", 3, 3, 2],
		["lupine", 3, 4, 3],
		["lupine", 1, 5, 1],
	]
	super()

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(4):
		starting_seeds.append(GenomeGenerator.wild_gene_dict("lupine"))
	starting_seeds[0]["max_flowers"] = [0, 0]
	starting_seeds[1]["max_flowers"] = [1, 0]
	starting_seeds[2]["red"] = ["r", "r"]
	starting_seeds[2]["blue"] = ["B", "B"]
	starting_seeds[2]["max_flowers"] = [1, 0]
	starting_seeds[3]["red"] = ["R", "r"]
	starting_seeds[3]["blue"] = ["b", "b"]
	starting_seeds[3]["max_flowers"] = [1, 0]
	return starting_seeds
