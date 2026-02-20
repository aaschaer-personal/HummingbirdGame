extends GridContainer

@onready var grid_unit_scene = preload("res://src/UI/punnet_unit.tscn")

func fill(gene_dict_1, gene_dict_2):
	var species = gene_dict_1["species"]
	if gene_dict_2["species"] != species:
		assert(false)

	for child in get_children():
		child.queue_free()

	if species in ["sunflower", "jewelweed", "zinnia"]:
		fill_one_gene(gene_dict_1, gene_dict_2)
	elif species in ["lupine", "hibiscus"]:
		fill_two_gene(gene_dict_1, gene_dict_2)
	elif species == "orchid":
		fill_three_gene(gene_dict_1, gene_dict_2)
	else:
		assert(false)

func fill_one_gene(gene_dict_1, gene_dict_2):
	var square_size = 2
	columns = square_size + 2
	var species = gene_dict_1["species"]
	assert(gene_dict_2["species"] == species)
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1_labels = []
	var p2_labels = []
	for a in [0,1]:
			var p1_label = Label.new()
			p1_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			p1_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			p1_label.text = str(p1_code[a])
			p1_labels.append(p1_label)
			
			var p2_label = Label.new()
			p2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			p2_label.text = str(p2_code[a], " ")
			p2_labels.append(p2_label)

	# child gene dicts
	var child_gene_dicts = []
	for p2_index in [0,1]:
		for p1_index in [0,1]:
			var child_dict = {"species": species}
			child_dict["color"] = [p1_code[p1_index], p2_code[p2_index]]
			child_gene_dicts.append(child_dict)

	_assemble(square_size, p1_labels, p2_labels, child_gene_dicts)

func fill_two_gene(gene_dict_1, gene_dict_2):
	var square_size = 4
	columns = square_size + 2
	var species = gene_dict_1["species"]
	assert(gene_dict_2["species"] == species)
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1_labels = []
	var p2_labels = []
	for a in [0,1]:
		for b in [2,3]:
			var p1_label = Label.new()
			p1_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			p1_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			p1_label.text = str(p1_code[a], p1_code[b])
			p1_labels.append(p1_label)
			
			var p2_label = Label.new()
			p2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			p2_label.text = str(p2_code[a], p2_code[b], " ")
			p2_labels.append(p2_label)

	# child gene dicts
	var child_gene_dicts = []

	var other_index = "other"
	if species == "lupine":
		other_index = "blue"

	for p2_red_i in [0,1]:
		for p2_other_i in [2,3]:
			for p1_red_i in [0,1]:
				for p1_other_i in [2,3]:
					var child_dict = {"species": species}
					child_dict["red"] = [p1_code[p1_red_i], p2_code[p2_red_i]]
					child_dict[other_index] = [p1_code[p1_other_i], p2_code[p2_other_i]]
					child_gene_dicts.append(child_dict)

	_assemble(square_size, p1_labels, p2_labels, child_gene_dicts)

func fill_three_gene(gene_dict_1, gene_dict_2):
	var square_size = 8
	columns = square_size + 2
	var species = gene_dict_1["species"]
	assert(gene_dict_2["species"] == species)
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1_labels = []
	var p2_labels = []
	for a in [0,1]:
		for b in [2,3]:
			for c in [4,5]:
				var p1_label = Label.new()
				p1_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				p1_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				p1_label.text = str(p1_code[a], p1_code[b], p1_code[c])
				p1_labels.append(p1_label)
				
				var p2_label = Label.new()
				p2_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				p2_label.text = str(p2_code[a], p2_code[b], p2_code[c], " ")
				p2_labels.append(p2_label)

	# child gene dicts
	var child_gene_dicts = []
	for p2_red_i in [0,1]:
		for p2_yellow_i in [2,3]:
			for p2_blue_i in [4,5]:
				for p1_red_i in [0,1]:
					for p1_yellow_i in [2,3]:
							for p1_blue_i in [4,5]:
								var child_dict = {"species": species}
								child_dict["red"] = [p1_code[p1_red_i], p2_code[p2_red_i]]
								child_dict["yellow"] = [p1_code[p1_yellow_i], p2_code[p2_yellow_i]]
								child_dict["blue"] = [p1_code[p1_blue_i], p2_code[p2_blue_i]]
								child_gene_dicts.append(child_dict)

	_assemble(square_size, p1_labels, p2_labels, child_gene_dicts)

func _make_space():
	var ret = Label.new()
	ret.text = "\n        "
	ret.add_theme_font_size_override("font_size", 6)
	return ret

func _assemble(square_size, p1_labels, p2_labels, child_gene_dicts):
	var child_units = []
	for child_gene_dict in child_gene_dicts:
		var unit = grid_unit_scene.instantiate()
		unit.call_deferred("fill", child_gene_dict)
		child_units.append(unit)

	# first row is just is p1 labels
	add_child(_make_space())
	for p1_label in p1_labels:
		add_child(p1_label)
	add_child(_make_space())

	# each row after that is a p2 label followed by grid units
	var child_index = 0
	for p2_label in p2_labels:
		add_child(p2_label)
		for i in range(square_size):
			add_child(child_units[child_index])
			child_index += 1
		add_child(_make_space())
