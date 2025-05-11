extends GridContainer

@onready var grid_unit_scene = preload("res://src/UI/punnet_unit.tscn")

func fill(gene_dict_1, gene_dict_2):
	var species = gene_dict_1["species"]
	if gene_dict_2["species"] != species:
		assert(false)

	for child in get_children():
		child.queue_free()

	if species == "sunflower":
		fill_one_gene(gene_dict_1, gene_dict_2)
	elif species == "jewelweed":
		fill_one_gene(gene_dict_1, gene_dict_2)
	elif species == "lupine":
		fill_two_gene(gene_dict_1, gene_dict_2)
	elif species == "zinnia":
		fill_one_gene(gene_dict_1, gene_dict_2)
	else:
		assert(false)

func _make_space():
	var ret = Label.new()
	ret.text = "\n        "
	ret.add_theme_font_size_override("font_size", 6)
	return ret

func fill_one_gene(gene_dict_1, gene_dict_2):
	columns = 4
	var child_units = []
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1a1 = Label.new()
	var p1a2 = Label.new()
	var p2a1 = Label.new()
	var p2a2 = Label.new()
	
	p1a1.text = p1_code[0]
	p1a2.text = p1_code[1]
	p2a1.text = p2_code[0]
	p2a2.text = p2_code[1]
	
	for label in [p1a1, p1a2]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for label in [p2a1, p2a2]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# child gene dicts
	var child_gene_dicts = []
	for i in range(4):
		child_gene_dicts.append({"species": gene_dict_1["species"]})
	
	for p2_index in [0,1]:
		for p1_index in [0,1]:
			child_gene_dicts[p2_index*2 + p1_index]["color"] = [p1_code[p1_index], p2_code[p2_index]]

	# assemble
	for child_gene_dict in child_gene_dicts:
		var unit = grid_unit_scene.instantiate()
		unit.call_deferred("fill", child_gene_dict)
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

func fill_two_gene(gene_dict_1, gene_dict_2):
	columns = 6
	var child_units = []
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1a1b1 = Label.new()
	var p1a1b2 = Label.new()
	var p1a2b1 = Label.new()
	var p1a2b2 = Label.new()

	var p2a1b1 = Label.new()
	var p2a1b2 = Label.new()
	var p2a2b1 = Label.new()
	var p2a2b2 = Label.new()
	
	p1a1b1.text = str(p1_code[0], p1_code[2])
	p1a1b2.text = str(p1_code[0], p1_code[3])
	p1a2b1.text = str(p1_code[1], p1_code[2])
	p1a2b2.text = str(p1_code[1], p1_code[3])
	
	p2a1b1.text = str(p2_code[0], p2_code[2])
	p2a1b2.text = str(p2_code[0], p2_code[3])
	p2a2b1.text = str(p2_code[1], p2_code[2])
	p2a2b2.text = str(p2_code[1], p2_code[3])
	
	for label in [p1a1b1, p1a1b2, p1a2b1, p1a2b2]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	for label in [p2a1b1, p2a1b2, p2a2b1, p2a2b2]:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# child gene dicts
	var child_gene_dicts = []
	for i in range(16):
		child_gene_dicts.append({"species": gene_dict_1["species"]})

	var child_index = 0
	for p2_red_i in [0,1]:
		for p2_blue_i in [0,1]:
			for p1_red_i in [0,1]:
				for p1_blue_i in [0,1]:
					child_gene_dicts[child_index]["red"] = [p1_code[p1_red_i], p2_code[p2_red_i]]
					child_gene_dicts[child_index]["blue"] = [p1_code[2 + p1_blue_i], p2_code[2 + p2_blue_i]]
					child_index += 1

	# assemble
	for child_gene_dict in child_gene_dicts:
		var unit = grid_unit_scene.instantiate()
		unit.call_deferred("fill", child_gene_dict)
		child_units.append(unit)

	add_child(_make_space())
	add_child(p1a1b1)
	add_child(p1a1b2)
	add_child(p1a2b1)
	add_child(p1a2b2)
	add_child(_make_space())

	add_child(p2a1b1)
	add_child(child_units[0])
	add_child(child_units[1])
	add_child(child_units[2])
	add_child(child_units[3])
	add_child(_make_space())

	add_child(p2a1b2)
	add_child(child_units[4])
	add_child(child_units[5])
	add_child(child_units[6])
	add_child(child_units[7])
	add_child(_make_space())
	
	add_child(p2a2b1)
	add_child(child_units[8])
	add_child(child_units[9])
	add_child(child_units[10])
	add_child(child_units[11])
	add_child(_make_space())
	
	add_child(p2a2b2)
	add_child(child_units[12])
	add_child(child_units[13])
	add_child(child_units[14])
	add_child(child_units[15])
	add_child(_make_space())
