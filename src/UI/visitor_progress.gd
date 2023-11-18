extends Control

@onready var visitor_manager = get_tree().get_first_node_in_group("visitor_manager")
@onready var label = $Label

var total_bouquets: int

func _ready():
	visitor_manager.boquet_accepted.connect(set_text)
	total_bouquets = len(visitor_manager.bouquet_order)
	set_text()

func set_text():
	var num_done = visitor_manager.bouquet_num
	label.text = ": " + str(num_done) + " / " + str(total_bouquets)
