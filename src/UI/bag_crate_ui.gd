class_name BagCrateUI extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var item_slots = $ItemSlots
@onready var mouse_item_node = $MouseItemNode
@onready var player_item_slot = $PlayerItemSlot
@onready var label_item_slot = $LabelItemSlot
@onready var exit_button = $ExitButton
@onready var shape_option = $ShapeOption
@onready var color_option = $ColorOption
@onready var compost_bin = $CompostBin
@onready var slot_scene = preload("res://src/UI/item_slot.tscn")
@onready var bag_scene = preload("res://src/items/seed_bag.tscn")

var num_slots = 20
var colors = [
	Color.WHITE,
	Color.LIGHT_PINK,
	Color.DARK_RED,
	Color.WEB_GREEN,
	Color.MEDIUM_BLUE,
	Color.BLUE_VIOLET
]

var mouse_item = null
var mouse_item_slot = null

func _ready():
	for i in range(num_slots):
		var new_slot = slot_scene.instantiate()
		item_slots.add_child(new_slot)
		new_slot.gui_input.connect(_on_slot_event.bind(new_slot))
		if i + 1 < num_slots:
			var new_bag = bag_scene.instantiate()
			add_child(new_bag)
			new_slot.place_item(new_bag)
	
	for color in colors:
		var swathe = Image.create(10, 10, false, Image.FORMAT_RGBA8)
		swathe.fill(color)
		var swathe_texture  = ImageTexture.create_from_image(swathe)
		color_option.add_icon_item(swathe_texture, "")
	
	player_item_slot.gui_input.connect(_on_slot_event.bind(player_item_slot))
	label_item_slot.gui_input.connect(_on_slot_event.bind(label_item_slot))
	shape_option.item_selected.connect(_on_selected)
	color_option.item_selected.connect(_on_selected)
	compost_bin.pressed.connect(compost)
	exit_button.pressed.connect(close)

func open():
	var player_item = player.held_item
	if player_item and player_item is SeedBag:
		player_item_slot.place_item(player.remove_held_item())
	get_tree().paused = true
	visible = true

func close():
	_return_mouse_item()
	if player_item_slot.item:
		player.pickup(player_item_slot.remove_item())
	get_tree().paused = false
	visible = false

func _return_mouse_item():
	if mouse_item:
		mouse_item_node.remove_child(mouse_item)
		mouse_item_slot.place_item(mouse_item)
		mouse_item = null
		mouse_item_slot = null

func _input(event):
	if mouse_item and event is InputEventMouseMotion:
		mouse_item.global_position = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_return_mouse_item()

func _on_slot_event(event, slot):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if mouse_item and slot.item:
					# add seeds from held bag to slot bag
					slot.item.add_seeds(mouse_item.remove_all_seeds())
				elif mouse_item and not slot.item:
					# put bag in slot
					mouse_item_node.remove_child(mouse_item)
					slot.place_item(mouse_item)
					mouse_item = null
					mouse_item_slot = null
					if slot == label_item_slot:
						_apply_label()
				elif not mouse_item and slot.item:
					# pickup bag from slot
					mouse_item = slot.remove_item()
					mouse_item.reparent(mouse_item_node)
					mouse_item.global_position = slot.global_position + event.position
					mouse_item_slot = slot

func _on_selected(_selected):
	_apply_label()

func _apply_label():
	var bag = label_item_slot.item
	if bag:
		var shape = shape_option.get_item_icon(shape_option.get_selected_id())
		var color = colors[color_option.get_selected_id()]
		bag.icon.texture = shape
		bag.icon.modulate = color
		
func compost():
	if mouse_item:
		mouse_item.remove_all_seeds()
