class_name CacheUI extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var exit_button = $ExitButton

# packets interface
@onready var packet_color_option = $PacketColorOption
@onready var icon_option = $IconOption
@onready var icon_color_option = $IconColorOption
@onready var packet_preview = $PacketPreview
@onready var icon_preview = $IconPreview
@onready var print_button = $PrintButton
@onready var packet_scene = preload("res://src/items/seed_packet.tscn")

var packets_toggled = true
var packets_remaining = 10
var colors = []

func _ready():
	var flower_species = get_tree().get_first_node_in_group("level").flower_species
	colors.append_array(Colors.flower_colors(flower_species))
	if Colors.white not in colors:
		colors.append(Colors.white)
	for color in colors:
		var swathe = Image.create(10, 10, false, Image.FORMAT_RGBA8)
		swathe.fill(color)
		var swathe_texture  = ImageTexture.create_from_image(swathe)
		packet_color_option.add_icon_item(swathe_texture, "")
		icon_color_option.add_icon_item(swathe_texture, "")
	
	exit_button.pressed.connect(close)
	for packet_option in [packet_color_option, icon_option, icon_color_option]:
		packet_option.item_selected.connect(_on_packet_option_selected)
	print_button.pressed.connect(print_packet)
	_on_packet_option_selected(null)

func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false

func _on_packet_option_selected(_selected):
	var packet_color = colors[packet_color_option.get_selected_id()]
	var icon = icon_option.get_item_icon(icon_option.get_selected_id())
	var icon_color = colors[icon_color_option.get_selected_id()]
	packet_preview.modulate = packet_color
	icon_preview.texture = icon
	icon_preview.modulate = icon_color

func print_packet():
	var packet_color = colors[packet_color_option.get_selected_id()]
	var icon = icon_option.get_item_icon(icon_option.get_selected_id())
	var icon_color = colors[icon_color_option.get_selected_id()]
	var packet = packet_scene.instantiate()
	packet.global_position = get_parent().global_position + Vector2(-2, -22)
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
		$PrintButton/Label.text = "No Paper"
	close()
