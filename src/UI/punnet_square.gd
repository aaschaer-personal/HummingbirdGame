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
	ret.text = "\n        "
	ret.add_theme_font_size_override("font_size", 6)
	return ret

func fill_sunflower(genome_dict_1, genome_dict_2):
	columns = 4
	var child_colors = [0,0,0,0]
	var child_units = []
	var p1_y = genome_dict_1["color"]
	var p2_y = genome_dict_2["color"]

	# Parent Labels
	var p1a1 = Label.new()
	p1a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p1a1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var p1a2 = Label.new()
	p1a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p1a2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var p2a1 = Label.new()
	p2a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var p2a2 = Label.new()
	p2a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if p1_y == 0:
		p1a1.text = "Y"
		p1a2.text = "Y"
	elif p1_y == 1:
		p1a1.text = "R"
		p1a2.text = "Y"
		child_colors[0] += 1
		child_colors[1] += 1
	elif p1_y == 2:
		p1a1.text = "R"
		p1a2.text = "R"
		child_colors[0] += 1
		child_colors[1] += 1
		child_colors[2] += 1
		child_colors[3] += 1
	else:
		assert(false)

	if p2_y == 0:
		p2a1.text = "Y"
		p2a2.text = "Y"
	elif p2_y == 1:
		p2a1.text = "R"
		p2a2.text = "R"
		child_colors[0] += 1
		child_colors[2] += 1
	elif p2_y == 2:
		p2a1.text = "Y"
		p2a2.text = "Y"
		child_colors[0] += 1
		child_colors[1] += 1
		child_colors[2] += 1
		child_colors[3] += 1
	else:
		assert(false)

	for child_color in child_colors:
		var unit = grid_unit_scene.instantiate()
		unit.call_deferred("fill_sunflower", child_color)
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
