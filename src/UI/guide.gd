extends NinePatchRect

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
