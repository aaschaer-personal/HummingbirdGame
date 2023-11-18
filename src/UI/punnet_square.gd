extends GridContainer

@onready var grid_unit_scene = preload("res://src/UI/punnet_unit.tscn")

func fill(genome_dict_1, genome_dict_2):
	if genome_dict_1["species"] != genome_dict_2["species"]:
		assert(false)

	for child in get_children():
		child.queue_free()

	if genome_dict_1["species"] == "Sunflower":
		fill_sunflower(genome_dict_1, genome_dict_2)
	else:
		assert(false)

func _make_space():
	var ret = Label.new()
	ret.text = "     "
	return ret

func fill_sunflower(genome_dict_1, genome_dict_2):
	columns = 4
	var child_yellows = [0,0,0,0]
	var child_units = []
	var p1_y = genome_dict_1["yellow"]
	var p2_y = genome_dict_2["yellow"]
	
	# Parent Labels
	var p1a1 = Label.new()
	p1a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var p1a2 = Label.new()
	p1a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var p2a1 = Label.new()
	p2a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var p2a2 = Label.new()
	p2a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if p1_y == 0:
		p1a1.text = "y"
		p1a2.text = "y"
	elif p1_y == 1:
		p1a1.text = "Y"
		p1a2.text = "y"
		child_yellows[0] += 1
		child_yellows[1] += 1
	elif p1_y == 2:
		p1a1.text = "Y"
		p1a2.text = "Y"
		child_yellows[0] += 1
		child_yellows[1] += 1
		child_yellows[2] += 1
		child_yellows[3] += 1
	else:
		assert(false)
	
	if p2_y == 0:
		p2a1.text = "y"
		p2a2.text = "y"
	elif p2_y == 1:
		p2a1.text = "Y"
		p2a2.text = "y"
		child_yellows[0] += 1
		child_yellows[2] += 1
	elif p2_y == 2:
		p2a1.text = "Y"
		p2a2.text = "Y"
		child_yellows[0] += 1
		child_yellows[1] += 1
		child_yellows[2] += 1
		child_yellows[3] += 1
	else:
		assert(false)

	for child_yellow in child_yellows:
		var unit = grid_unit_scene.instantiate()
		unit.call_deferred("fill_sunflower", child_yellow)
		child_units.append(unit)

	add_child(_make_space())
	add_child(p1a1)
	add_child(p1a2)
	add_child(_make_space())
	
	add_child(p2a1)
	add_child(child_units[0])
	add_child(child_units[1])
	add_child(_make_space())
	
	add_child(p2a2)
	add_child(child_units[2])
	add_child(child_units[3])
	add_child(_make_space())
