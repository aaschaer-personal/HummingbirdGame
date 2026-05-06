extends ZinniaLevel


func _ready():
	level_num = 4
	level_intro_text = """Welcome to the Zinnia cache!
Here we test your mastery of a single gene with 4 different alleles that combine into six different colors.

Your starting seeds' color genes are RY, Rw, and FF."""
	# colors, count, size, max_repetitions
	bouquet_recipes = [
		[[Colors.orange, Colors.pink], 1, 2, 1],
		[[Colors.red, [Colors.yellow, Colors.white]], 2, 2, 1],
		[[Colors.fushia], 1, 2, 2],
		["zinnia", 3, 3, 2],
		["zinnia", 3, 4, 3],
		["zinnia", 1, 5, 3],
		["zinnia", 1, 5, 1],
	]
	super()

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(3):
		starting_seeds.append(GenomeGenerator.wild_gene_dict("zinnia"))
	starting_seeds[0]["max_flowers"] = [1, 0]
	starting_seeds[0]["color"] = ["R", "w"]
	starting_seeds[1]["max_flowers"] = [1, 0]
	starting_seeds[1]["color"] = ["R", "Y"]
	starting_seeds[2]["max_flowers"] = [0, 0]
	starting_seeds[2]["color"] = ["F", "F"]
	return starting_seeds
