extends NinePatchRect

@onready var level = get_tree().get_first_node_in_group("level")
@onready var tabs = $Tabs
@onready var content = $Content
@onready var controls_tab = $Tabs/Controls
@onready var using_items_tab = $Tabs/UsingItems
@onready var growing_flowers_tab = $Tabs/GrowingFlowers
@onready var nectar_and_pollen_tab = $Tabs/NectarAndPollen
@onready var energy_tab = $Tabs/Energy
@onready var visitors_tab = $Tabs/Visitors
@onready var printing_packets_tab = $Tabs/PrintingPackets
@onready var genetics_tab = $Tabs/Genetics
@onready var punnet_square_tab = $Tabs/PunnetSquare
@onready var genetics_content = $Content/Genetics
@onready var exit_button = $ExitButton

func _ready():
	controls_tab.pressed.connect(toggle.bind("Controls"))
	using_items_tab.pressed.connect(toggle.bind("UsingItems"))
	growing_flowers_tab.pressed.connect(toggle.bind("GrowingFlowers"))
	nectar_and_pollen_tab.pressed.connect(toggle.bind("NectarAndPollen"))
	energy_tab.pressed.connect(toggle.bind("Energy"))
	visitors_tab.pressed.connect(toggle.bind("Visitors"))
	printing_packets_tab.pressed.connect(toggle.bind("PrintingPackets"))
	genetics_tab.pressed.connect(toggle.bind("Genetics"))
	punnet_square_tab.pressed.connect(toggle.bind("PunnetSquare"))
	exit_button.pressed.connect(close)
	
	if level:
		if level.flower_species == "sunflower":
			genetics_content.text = genetics_content.text % "* Sunflowers have one color gene with two alleles, R for red and Y for yellow. This means there are three unique combinations RR, RY, and YY that produce red, orange, and yellow flowers."
		elif level.flower_species == "jewelweed":
			genetics_content.text = genetics_content.text % "* Jewelweed has one color gene with three alleles, R for red, P for purple, and Y for yellow. There are six unique combinations which produce four different colors."
		elif level.flower_species == "lupine":
			genetics_content.text = genetics_content.text % "* Lupines have two color genes with two alleles each for nine unique combinations. The red gene has alleles R and r, with R adding red to the flower. The blue gene has alleles B and b, with B adding blue to the flower."
		elif level.flower_species == "zinnia":
			genetics_content.text = genetics_content.text % "* Zinnias have one color gene with four alleles, R for red, F for Fushia, Y for yellow, and W for white. There are ten unique combinations which produce six different colors."
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

func close():
	visible = false
