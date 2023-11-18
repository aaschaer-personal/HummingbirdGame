class_name SeedPacket extends Item

@onready var seed_count = $SeedCount
@onready var icon = $Icon
var seeds = []

func _ready():
	add_to_group("seed_packets")
	seed_count.text = "0"

func is_interactable():
	return !disk_sprite.visible and get_parent() is Main and (
		player.held_item == null or player.held_item is SeedPacket
	)

func get_player_interaction():
	if player.held_item is SeedPacket:
		return "transfer_seeds"
	else:
		return "pickup"

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

func generate_starting_seeds():
	pass
