extends HibiscusLevel


func _ready():
	level_num = 5
	level_intro_text = """Welcome to the Hibiscus cache!
This test is a bit unique with different numbers of alleles across two color genes. Take note that if the red gene is RR the flower will be red regardless of the other color gene!

Your starting seeds' color genes are RRYY, RrBw, and rrww."""
	var easy_colors = [Colors.red,  Colors.white]
	var medium_colors = [Colors.purple, Colors.orange, Colors.pink,]
	var hard_colors = [Colors.blue, Colors.yellow]
	# colors, count, size, max_repetitions
	bouquet_recipes = [
		[easy_colors, 1, 2, 1],
		[[easy_colors, medium_colors], 2, 2, 1],
		[[easy_colors, easy_colors, medium_colors], 1, 3, 2],
		[[easy_colors, medium_colors, medium_colors], 1, 3, 2],
		[[easy_colors, easy_colors, hard_colors], 1, 3, 2],
		[[easy_colors, medium_colors, hard_colors], 1, 3, 2],
		["hibiscus", 4, 4, 3],
		[[easy_colors, medium_colors, medium_colors, hard_colors, hard_colors], 3, 5, 2],
		[medium_colors + hard_colors, 1, 5, 1],
	]
	super()

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(3):
		starting_seeds.append(GenomeGenerator.wild("hibiscus"))
	starting_seeds[0]["max_flowers"] = 1
	starting_seeds[0]["red"] = ["R", "R"]
	starting_seeds[0]["other"] = ["Y", "Y"]
	starting_seeds[1]["max_flowers"] = 1
	starting_seeds[1]["red"] = ["R", "r"]
	starting_seeds[1]["other"] = ["B", "w"]
	starting_seeds[2]["max_flowers"] = 1
	starting_seeds[2]["red"] = ["r", "r"]
	starting_seeds[2]["other"] = ["w", "w"]
	return starting_seeds
