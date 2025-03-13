class_name VisitorManager extends Node2D

signal visitor_arrived(desired_bouquet_colors)
signal visitor_left
signal boquet_accepted

@onready var timer = $Timer
var bouquets = []
var bouquet_num = 0
var bouquets_done = 0
var done = false
var visitors_unlocked = false

var visitor_spawns: Array
var num_visitors = 0
var max_visitors: int
var visitor_scene: Resource

var rainbow_order = {
	Colors.red: 0,
	Colors.pink: 1,
	Colors.orange: 2,
	Colors.yellow: 3,
	Colors.blue: 4,
	Colors.purple: 5,
	Colors.white: 6,
}

# colors, count, size, max_repetitions
var bouquet_recipes_by_species = {
	"sunflower": [
		[[Colors.yellow], 1, 1, 1],
		[[Colors.orange], 1, 1, 1],
		["sunflower", 2, 2, 1],
		["sunflower", 1, 3, 1],
	],
	"jewelweed": [
		[[Colors.red, Colors.yellow], 1, 1, 1],
		[[Colors.orange, Colors.purple], 1, 1, 1],
		["jewelweed", 3, 2, 1],
		["jewelweed", 2, 3, 2],
		["jewelweed", 1, 4, 1],
	],
	"lupine": [
		[[Colors.purple, Colors.blue, Colors.pink], 2, 2, 1],
		[[Colors.red, Colors.white], 1, 1, 1],
		[[Colors.purple, Colors.blue, Colors.pink], 1, 3, 2],
		[[Colors.red, Colors.white], 1, 2, 1],
		["lupine", 3, 3, 2],
		["lupine", 3, 4, 3],
		["lupine", 1, 5, 1],
	],
}

func _ready():
	var level = get_tree().get_first_node_in_group("level")
	var visitor_species = level.visitor_species
	visitor_spawns = get_tree().get_nodes_in_group("visitor_spawns")
	max_visitors = len(visitor_spawns)

	visitor_scene = load("res://src/visitors/%s.tscn" % visitor_species)
	var flower_species = level.flower_species

	for recipe in bouquet_recipes_by_species[flower_species]:
		for bouquet in callv("generate_boquets", recipe):
			bouquets.append(bouquet)
	timer.timeout.connect(_on_timeout)

func _color_compare(color1, color2):
	return rainbow_order[color1] < rainbow_order[color2]

func generate_boquets(colors, count, size, max_repetitions):
	if colors is String:
		colors = Colors.flower_colors(colors)
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

func spawn_visitor():
	var spawn
	for potential_spawn in visitor_spawns:
		if potential_spawn.visitor == null:
			spawn = potential_spawn
			break
	var visitor = visitor_scene.instantiate()
	add_sibling(visitor)
	spawn.visitor = visitor
	visitor.desired_bouquet_colors = bouquets[bouquet_num]
	bouquet_num += 1
	num_visitors += 1
	await visitor.land(spawn)
	visitor_arrived.emit(visitor.desired_bouquet_colors)

func on_visitor_left(visitor):
	await visitor.tree_exited
	visitor.spawn.visitor = null
	num_visitors -= 1
	visitor_left.emit()
	if timer.is_stopped():
		timer.start(5)

func _on_timeout():
	if bouquet_num < len(bouquets):
		spawn_visitor()
		if num_visitors < max_visitors:
			timer.start(5)
		else:
			timer.stop()
	else:
		timer.stop()

func finish_bouquet():
	bouquets_done += 1
	boquet_accepted.emit()
	if bouquets_done == len(bouquets):
		done = true
		timer.stop()
