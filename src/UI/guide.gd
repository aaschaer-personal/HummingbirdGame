extends NinePatchRect

@onready var level = get_tree().get_first_node_in_group("level")
@onready var tabs = $Tabs
@onready var content = $Content
@onready var controls_tab = $Tabs/Controls
@onready var using_items_tab = $Tabs/UsingItems
@onready var growing_flowers_tab = $Tabs/GrowingFlowers
@onready var energy_tab = $Tabs/Energy
@onready var visitors_tab = $Tabs/Visitors
@onready var printing_packets_tab = $Tabs/PrintingPackets
@onready var genetics_tab = $Tabs/Genetics
@onready var punnet_square_tab = $Tabs/PunnetSquare
@onready var species_details = $Content/Genetics/SpeciesDetails
@onready var example_punnet_square = $Content/Genetics/CrossContainer/PunnetSquare
@onready var exit_button = $ExitButton

func _ready():
	controls_tab.pressed.connect(toggle.bind("Controls"))
	using_items_tab.pressed.connect(toggle.bind("UsingItems"))
	growing_flowers_tab.pressed.connect(toggle.bind("GrowingFlowers"))
	energy_tab.pressed.connect(toggle.bind("Energy"))
	visitors_tab.pressed.connect(toggle.bind("Visitors"))
	printing_packets_tab.pressed.connect(toggle.bind("PrintingPackets"))
	genetics_tab.pressed.connect(toggle.bind("Genetics"))
	punnet_square_tab.pressed.connect(toggle.bind("PunnetSquare"))
	exit_button.pressed.connect(close)
	var options = get_tree().get_first_node_in_group("options")
	options.label_colors_changed.connect(set_color_labels)
	set_color_labels(Config.get_option("label_colors"))
	example_punnet_square.fill(
		{"species": "sunflower", "color": ["R", "Y"]},
		{"species": "sunflower", "color": ["Y", "Y"]},
	)

	if level:
		await level.ready
		if level.flower_species == "sunflower":
			# sunflowers are explained in the example
			species_details.visible = false
		elif level.flower_species == "jewelweed":
			species_details.text = "* Jewelweeds have one color locus with three alleles, R for red, P for purple, and Y for yellow. There are six unique combinations which produce four different colors."
		elif level.flower_species == "lupine":
			species_details.text = "* Lupines have two color loci with two alleles. The red locus has alleles R and r, with R adding red to the flower. The blue locus has alleles B and b, with B adding blue to the flower. There are nine unique combinations that produce five different colors."
		elif level.flower_species == "zinnia":
			species_details.text = "* Zinnias have one color locus with four alleles, R for red, F for Fushia, Y for yellow, and W for white. There are ten unique combinations which produce six different colors."
		elif level.flower_species == "hibiscus":
			species_details.text = "* Hibiscuses have two color loci. The red locus has alleles R and r, with R adding red to the flower. The other locus can be B for blue, Y for yellow, or W for white. There are eighteen unique combinations which produce seven different colors."
		elif level.flower_species == "orchid":
			species_details.text = "* Orchids have three color loci. The red locus has alleles R and r, with R adding red to the flower. The yellow locus has alleles Y and y, with Y adding blue to the flower. The blue locus has alleles B and b, with B adding blue to the flower. There are twenty-seven unique combinations which produce nine different colors."
		else:
			assert(level == null)

func toggle(tab_name):
	for tab in tabs.get_children():
		if tab.name == tab_name:
			if not tab.disabled:
				tab.disabled = true
				Helpers.get_only_child(tab).position += Vector2(0,1)
		else:
			if tab.disabled:
				tab.disabled = false
				Helpers.get_only_child(tab).position += Vector2(0,-1)
				
	for blob in content.get_children():
			blob.visible = blob.name == tab_name

func set_color_labels(label_colors):
	var deliver_flower = $Content/Visitors/DeliverFlower
	var deliver_bouquet = $Content/Visitors/DeliverBouquet
	var gene_flowers = $Content/Genetics/GeneFlowers
	var cross = $Content/Genetics/CrossContainer/Cross
	var deliver_flower_labeled = $Content/Visitors/DeliverFlowerLabeled
	var deliver_bouquet_labeled = $Content/Visitors/DeliverBouquetLabeled
	var gene_flowers_labeled = $Content/Genetics/GeneFlowersLabeled
	var cross_labeled = $Content/Genetics/CrossContainer/CrossLabeled
	deliver_flower.visible = not label_colors
	deliver_bouquet.visible = not label_colors
	gene_flowers.visible = not label_colors
	cross.visible = not label_colors
	deliver_flower_labeled.visible = label_colors
	deliver_bouquet_labeled.visible = label_colors
	gene_flowers_labeled.visible = label_colors
	cross_labeled.visible = label_colors

func close():
	visible = false
