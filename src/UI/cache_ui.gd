class_name CacheUI extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var exit_button = $ExitButton
@onready var packets_button = $PacketsButton
@onready var genetics_button = $GeneticsButton

# packets interface
@onready var packets_interface = $PacketsInterface
@onready var packet_color_option = $PacketsInterface/PacketColorOption
@onready var icon_option = $PacketsInterface/IconOption
@onready var icon_color_option = $PacketsInterface/IconColorOption
@onready var packet_preview = $PacketsInterface/PacketPreview
@onready var icon_preview = $PacketsInterface/IconPreview
@onready var print_button = $PacketsInterface/PrintButton
@onready var packet_scene = preload("res://src/items/seed_packet.tscn")

# genetics interface
@onready var genetics_interface = $GeneticsInterface
@onready var punnet_square = $GeneticsInterface/PunnetContainer/PunnetSquare
@onready var p1a1 = $GeneticsInterface/P1/A1
@onready var p1a2 = $GeneticsInterface/P1/A2
@onready var p1b1 = $GeneticsInterface/P1/B1
@onready var p1b2 = $GeneticsInterface/P1/B2
@onready var p1c1 = $GeneticsInterface/P1/C1
@onready var p1c2 = $GeneticsInterface/P1/C2
@onready var p2a1 = $GeneticsInterface/P2/A1
@onready var p2a2 = $GeneticsInterface/P2/A2
@onready var p2b1 = $GeneticsInterface/P2/B1
@onready var p2b2 = $GeneticsInterface/P2/B2
@onready var p2c1 = $GeneticsInterface/P2/C1
@onready var p2c2 = $GeneticsInterface/P2/C2


var packets_toggled = true
var packets_remaining = 9
var species

var colors = [
	Colors.white,
	Colors.yellow,
	Colors.orange,
]

func _ready():
	for color in colors:
		var swathe = Image.create(10, 10, false, Image.FORMAT_RGBA8)
		swathe.fill(color)
		var swathe_texture  = ImageTexture.create_from_image(swathe)
		packet_color_option.add_icon_item(swathe_texture, "")
		icon_color_option.add_icon_item(swathe_texture, "")
	
	exit_button.pressed.connect(close)
	packets_button.pressed.connect(toggle)
	genetics_button.pressed.connect(toggle)
	for packet_option in [packet_color_option, icon_option, icon_color_option]:
		packet_option.item_selected.connect(_on_packet_option_selected)
	print_button.pressed.connect(print)
	for gene_option in [p1a1, p1a2, p1b1, p1b2, p1c1, p1c2, p2a1, p2a2, p2b1, p2b2, p2c1, p2c2]:
		gene_option.item_selected.connect(_on_gene_option_selected)

func initialize_genetics(new_species):
	species = new_species
	if species == "Sunflower":
		for option in [p1a1, p1a2, p2a1, p2a2]:
			option.visible = true
			option.add_item("Y")
			option.add_item("y")
		p1a1.select(0)
		p1a2.select(1)
		p2a1.select(0)
		p2a2.select(1)
		_on_gene_option_selected(null)
	else:
		assert(false)

func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false

func toggle():
	packets_button.button_pressed = not packets_toggled
	packets_button.disabled = not packets_toggled
	genetics_button.button_pressed = packets_toggled
	genetics_button.disabled = packets_toggled
	packets_interface.visible = not packets_toggled
	genetics_interface.visible = packets_toggled
	if packets_toggled:
		$PacketsButton/Label.position += Vector2(0,-1)
		$GeneticsButton/Label.position += Vector2(0,1)
	else:
		$PacketsButton/Label.position += Vector2(0,1)
		$GeneticsButton/Label.position += Vector2(0,-1)
	packets_toggled = not packets_toggled

func _on_packet_option_selected(_selected):
	var packet_color = colors[packet_color_option.get_selected_id()]
	var icon = icon_option.get_item_icon(icon_option.get_selected_id())
	var icon_color = colors[icon_color_option.get_selected_id()]
	packet_preview.modulate = packet_color
	icon_preview.texture = icon
	icon_preview.modulate = icon_color

func print():
	var packet_color = colors[packet_color_option.get_selected_id()]
	var icon = icon_option.get_item_icon(icon_option.get_selected_id())
	var icon_color = colors[icon_color_option.get_selected_id()]
	var packet = packet_scene.instantiate()
	get_parent().add_sibling(packet)
	if not packet.is_node_ready():
		await packet.ready

	packet.item_sprite.modulate = packet_color
	packet.icon.texture = icon
	packet.icon.modulate = icon_color
	get_parent().print_packet(packet)
	packets_remaining -= 1
	if packets_remaining == 0:
		print_button.disabled = true
		$PacketsInterface/PrintButton/Label.text = "No Paper"
	close()

func _on_gene_option_selected(_selected):
	var g1 = {"species": species}
	var g2 = {"species": species}

	if species == "Sunflower":
		g1["yellow"] = 0
		g2["yellow"] = 0
		if p1a1.get_selected_id() == 0:
			g1["yellow"] += 1
		if p1a2.get_selected_id() == 0:
			g1["yellow"] += 1
		if p2a1.get_selected_id() == 0:
			g2["yellow"] += 1
		if p2a2.get_selected_id() == 0:
			g2["yellow"] += 1
	else:
		assert(false)

	punnet_square.fill(g1, g2)
