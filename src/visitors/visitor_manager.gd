class_name VisitorManager extends Node2D

signal visitor_arrived(desired_bouquet_colors)
signal visitor_left
signal boquet_accepted

@onready var spawn_point = $SpawnPoint
@onready var landing_point = $LandingPoint
@onready var timer = $Timer
@onready var visitor_scene = preload("res://src/visitors/visitor.tscn")
@onready var visitor: Visitor
@onready var visitors_unlocked = false

var rainbow_order = {
	Colors.red: 0,
	Colors.orange: 1,
	Colors.yellow: 2,
	Colors.purple: 3,
}

func _color_compare(color1, color2):
	return rainbow_order[color1] < rainbow_order[color2]

func generate_boquets(colors, count, size, max_repetitions):
	var ret = []
	for i in range(count):
		while true:
			var bouquet = []
			for j in range(size):
				while true:
					var color = colors[randi() % len(colors)]
					if bouquet.count(color) < max_repetitions:
						bouquet.append(color)
						break
			bouquet.sort_custom(_color_compare)
			if bouquet not in ret:
				ret.append(bouquet)
				break
	return ret

var bouquet_tiers_by_species = {
	"sunflower": [
		[[Colors.yellow]],
		[[Colors.orange]],
		generate_boquets(Colors.flower_colors("sunflower"), 2, 2, 1),
		[[Colors.red, Colors.orange, Colors.yellow]],
	],
	"jewelweed": [
		generate_boquets([Colors.red, Colors.yellow], 1, 1, 1),
		generate_boquets([Colors.orange, Colors.purple], 1, 1, 1),
		generate_boquets(Colors.flower_colors("jewelweed"), 3, 2, 1),
		generate_boquets(Colors.flower_colors("jewelweed"), 2, 3, 2),
		[[Colors.red, Colors.orange, Colors.yellow, Colors.purple]],
	]
}

var bouquets = []
var bouquet_num = 0
var done = false

func _ready():
	var species = get_tree().get_first_node_in_group("level").species
	for tier in bouquet_tiers_by_species[species]:
		for bouquet in tier:
			bouquets.append(bouquet)
	timer.timeout.connect(_on_timeout)
	timer.start(1)

func spawn_visitor():
	if visitor == null:
		await get_tree().create_timer(5).timeout
		visitor = visitor_scene.instantiate()
		add_child(visitor)
		visitor.desired_bouquet_colors = bouquets[bouquet_num]
		visitor.set_position(spawn_point.position)
		await visitor.land(landing_point)
		visitor_arrived.emit(visitor.desired_bouquet_colors)
	else:
		timer.start(1)

func on_visitor_left():
	visitor.queue_free()
	if bouquet_num == len(bouquets):
		done = true
	else:
		timer.start(5)
	await visitor.tree_exited
	visitor = null
	visitor_left.emit()

func _on_timeout():
	if visitors_unlocked:
		spawn_visitor()
		timer.stop()
	else:
		timer.start(1)

func finish_bouquet():
	bouquet_num += 1
	boquet_accepted.emit()
