extends JewelweedLevel


func _ready():
	level_num = 2
	level_intro_text = """Welcome to the Jewelweed cache!
Here we expand on the basics by adding another color allele, P for purple. Take note that purple is dominant over yellow, with both PP and PY resulting in purple flowers.

Your starting seeds' color genes are RR, YY, and PP."""
	# colors, count, size, max_repetitions
	bouquet_recipes = [
		[[Colors.red, Colors.yellow], 1, 1, 1],
		[[Colors.orange, Colors.purple], 1, 1, 1],
		["jewelweed", 3, 2, 1],
		["jewelweed", 2, 3, 2],
		["jewelweed", 1, 4, 1],
	]
	super()

func generate_starting_seeds():
	var starting_seeds = []
	for i in range(3):
		starting_seeds.append(GenomeGenerator.wild_gene_dict("jewelweed"))
	starting_seeds[0]["max_flowers"] = [1, 0]
	starting_seeds[0]["color"] = ["R", "R"]
	starting_seeds[2]["max_flowers"] = [1, 0]
	starting_seeds[2]["color"] = ["Y", "Y"]
	starting_seeds[1]["max_flowers"] = [0, 0]
	starting_seeds[1]["color"] = ["P", "P"]
	return starting_seeds
