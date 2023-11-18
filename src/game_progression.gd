extends Node

signal score_changed(score)
@onready var score = 0
@onready var customers_unlocked = false
@onready var first_bouquet = true
@onready var target_difficulty = 1
@onready var num_bouquets = 0
@onready var last_ten_flowers = []
@onready var flower_options = {
	"Lupine": {
		Color.BLUE_VIOLET: {
			"weight": 9.0,
			"difficulty": 1,
			"grown": false,
		},
		Color.MEDIUM_BLUE: {
			"weight": 3.0,
			"difficulty": 2,
			"grown": false,
		},
		Color.LIGHT_PINK: {
			"weight": 2.0,
			"difficulty": 4,
			"grown": false,
		},
		Color.DARK_RED: {
			"weight": 1.0,
			"difficulty": 4,
			"grown": false,
		},
		Color.WHITE: {
			"weight": 1.0,
			"difficulty": 4,
			"grown": false,
		}
	}
}

func _weighted_random_choice(items: Array):
	var rand = randf()
	var weight_sum = 0
	for item in items:
		weight_sum += item["weight"]
		if rand < weight_sum:
			return item
	# fallback to last item if sum does not quite reach 1 due to rounding
	return items.back()

func _difficulty_comp(d1: Dictionary, d2: Dictionary):
	return d1["difficulty"] < d2["difficulty"]

func generate_desired_boquet():
	var ret = []
	if first_bouquet:
		ret.append({
			"species": "Lupine",
			"color": Color.BLUE_VIOLET,
			"difficulty": 1,
		})
		first_bouquet = false
		return ret

	var options = []
	for species in flower_options.keys():
		for color in flower_options[species].keys():
			var data = flower_options[species][color]
			var option = {
				"species": species,
				"color": color,
				"weight": data["weight"],
				"difficulty": data["difficulty"]
			}
			# flowers not yet grown are 5 times less likely
			if not data["grown"]:
				option["weight"] /= 5
			# flowers appearing n times in the last 10 are n times less likely
			var last_ten_count = 0
			for flower in last_ten_flowers:
				if flower["species"] == species and flower["color"] == color:
					last_ten_count += 1
			if last_ten_count:
				option["weight"] /= last_ten_count

			options.append(option)

	# adjust weights to sum to 1.0 and set difficulty as a convenience
	var weight_sum = 0.0
	for option in options:
		weight_sum += option["weight"]
	for option in options:
		option["weight"] /= weight_sum

	# weighted random selection until we hit 5 or are greater than target
	var bouquet_difficulty = 0
	while not (ret.size() >= 5 or bouquet_difficulty >= target_difficulty):
		var rand_choice = _weighted_random_choice(options)
		ret.append(rand_choice)
		bouquet_difficulty += rand_choice["difficulty"]

	# see if we can remove items while still being above target
	ret.sort_custom(_difficulty_comp)
	while bouquet_difficulty > target_difficulty:
		if bouquet_difficulty - ret[0]["difficulty"] > target_difficulty:
			bouquet_difficulty -= ret[0]["difficulty"]
			ret.remove_at(0)
		else:
			break

	return ret

func unlock_flower(species, color):
	flower_options[species][color]["grown"] = true
	
	if not customers_unlocked:
		customers_unlocked = true

func process_bouquet(bouquet: Bouquet):
	for flower in bouquet.get_flowers():
		last_ten_flowers.append({
			"species": flower.species,
			"color": flower.color,
		})
	last_ten_flowers = last_ten_flowers.slice(-10)
	num_bouquets += 1

func add_points(points_dict):
	if points_dict["difficulty"] == target_difficulty:
		target_difficulty += 1
	else:
		target_difficulty -= 2
		if target_difficulty < 1:
			target_difficulty = 1

	score += (points_dict["accuracy"]
		+ points_dict["difficulty"]
		+ points_dict["time"]
	)
	score_changed.emit(score)
