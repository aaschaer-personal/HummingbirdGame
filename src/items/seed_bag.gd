class_name SeedBag extends Item

@onready var seed_count = $SeedCount
@onready var icon = $Icon
var seeds = []

func _ready():
	seed_count.text = "0"

func remove_all_seeds():
	var removed_seeds = seeds
	seeds = []
	seed_count.text = str(len(seeds))
	return removed_seeds

func remove_seed():
	var removed_seed = seeds.pop_back()
	seed_count.text = str(len(seeds))
	return removed_seed
	
func add_seeds(new_seeds):
	seeds.append_array(new_seeds)
	seeds.shuffle()
	seed_count.text = str(len(seeds))
