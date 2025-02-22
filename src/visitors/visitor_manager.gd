class_name VisitorManager extends Node2D

signal visitor_arrived(desired_bouquet_colors)
signal visitor_left
signal boquet_accepted

@onready var spawn_point = $SpawnPoint
@onready var landing_point = $LandingPoint
@onready var timer = $Timer
@onready var visitor: Visitor
@onready var visitors_unlocked = false
var bouquets = []
var bouquet_num = 0
var done = false
var visitor_scene = null

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
		[[Colors.purple], 1, 1, 1],
		[[Colors.purple, Colors.blue, Colors.pink], 2, 2, 1],
		[[Colors.red, Colors.white], 2, 1, 1],
		[[Colors.purple, Colors.blue, Colors.pink], 2, 3, 2],
		[[Colors.pink, Colors.red, Colors.white], 1, 2, 1],
		["lupine", 2, 3, 2],
		["lupine", 3, 4, 2],
		["lupine", 1, 5, 1],
	],
}

func _ready():
	var level = get_tree().get_first_node_in_group("level")
	var visitor_species = level.visitor_species
	visitor_scene = load("res://src/visitors/%s.tscn" % visitor_species)
	var flower_species = level.flower_species

	for recipe in bouquet_recipes_by_species[flower_species]:
		for bouquet in callv("generate_boquets", recipe):
			bouquets.append(bouquet)
	timer.timeout.connect(_on_timeout)
	timer.start(1)

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
