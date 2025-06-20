extends Control

@onready var visitor_manager = get_tree().get_first_node_in_group("visitor_manager")
@onready var label = $Label
@onready var visitor_icon = $VisitorIcon

func _ready():
	var texture = get_tree().get_first_node_in_group("level").visitor_icon_texture
	visitor_icon.texture = texture
	visitor_manager.ready.connect(set_text)
	visitor_manager.boquet_accepted.connect(set_text)

func set_text():
	var total_bouquets = len(visitor_manager.bouquets)
	var num_done = visitor_manager.bouquets_done
	label.text = " : " + str(num_done) + "/" + str(total_bouquets)
