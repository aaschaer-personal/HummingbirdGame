extends GridContainer

@onready var grid_unit_scene = preload("res://src/UI/punnet_unit.tscn")

func fill(gene_dict_1, gene_dict_2):
	var species = gene_dict_1["species"]
	if gene_dict_2["species"] != species:
		assert(false)

	for child in get_children():
		child.queue_free()

	if species == "sunflower":
		fill_sunflower_or_jewelweed(gene_dict_1, gene_dict_2)
	elif species == "jewelweed":
		fill_sunflower_or_jewelweed(gene_dict_1, gene_dict_2)
	else:
		assert(false)

func _make_space():
	var ret = Label.new()
	ret.text = "\n        "
	ret.add_theme_font_size_override("font_size", 6)
	return ret

func fill_sunflower_or_jewelweed(gene_dict_1, gene_dict_2):
	columns = 4
	var child_units = []
	var p1_code = GenomeHelpers.code_from_gene_dict(gene_dict_1)
	var p2_code = GenomeHelpers.code_from_gene_dict(gene_dict_2)

	# parent Labels
	var p1a1 = Label.new()
	p1a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p1a1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p1a1.text = p1_code[0]
	var p1a2 = Label.new()
	p1a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p1a2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p1a2.text = p1_code[1]
	var p2a1 = Label.new()
	p2a1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p2a1.text = p2_code[0]
	var p2a2 = Label.new()
	p2a2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p2a2.text = p2_code[1]

	# child gene dicts
	var child_gene_dicts = []
	for i in range(4):
		child_gene_dicts.append({"species": gene_dict_1["species"]})
	child_gene_dicts[0]["color"] = [p1_code[0], p2_code[0]]
	child_gene_dicts[1]["color"] = [p1_code[1], p2_code[0]]
	child_gene_dicts[2]["color"] = [p1_code[0], p2_code[1]]
	child_gene_dicts[3]["color"] = [p1_code[1], p2_code[1]]

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
