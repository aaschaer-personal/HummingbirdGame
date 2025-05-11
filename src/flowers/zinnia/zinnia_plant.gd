class_name ZinniaPlant extends Plant

func _rand_flower_positions():
	var positions = [1,2]
	positions.shuffle()
	positions.insert(0, 0)
	return positions
