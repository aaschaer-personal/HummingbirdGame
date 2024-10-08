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

var species = "Sunflower"
var done = false
var bouquet_colors = [
	[Colors.yellow],
	[Colors.orange],
	[Colors.red, Colors.yellow],
	[Colors.red, Colors.orange],
	[Colors.orange, Colors.yellow],
	[Colors.red, Colors.orange, Colors.yellow],
]
var bouquet_order = [
	[0], [1], [2,3,4], [2,3,4], [5]
]
var bouquet_num = 0
var current_bouquet_index
var delivered_bouquet_indexes = []

func _ready():
	timer.timeout.connect(_on_timeout)
	timer.start(1)

func spawn_visitor():
	if visitor == null:
		await get_tree().create_timer(5).timeout
		visitor = visitor_scene.instantiate()
		add_child(visitor)
		visitor.desired_bouquet_colors = generate_desired_boquet_colors()
		visitor.set_position(spawn_point.position)
		await visitor.land(landing_point)
		visitor_arrived.emit(visitor.desired_bouquet_colors)
	else:
		timer.start(1)

func on_visitor_left():
	visitor.queue_free()
	if bouquet_num == len(bouquet_order):
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

func generate_desired_boquet_colors():
	var possible_bouquet_indexes = []
	for bouquet_index in bouquet_order[bouquet_num]:
		if bouquet_index not in delivered_bouquet_indexes:
			possible_bouquet_indexes.append(bouquet_index)
	var chosen_index = possible_bouquet_indexes[
		randi() % possible_bouquet_indexes.size()]

	current_bouquet_index = chosen_index
	return bouquet_colors[chosen_index]

func finish_bouquet():
	bouquet_num += 1
	delivered_bouquet_indexes.append(current_bouquet_index)
	boquet_accepted.emit()
