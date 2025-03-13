class_name Bouquet extends Node2D

@onready var node_positions = [
	Vector2(0, 0), Vector2(-2, -2), Vector2(-2, 2),
	Vector2(-4, -4), Vector2(-4, 4),
]
@onready var node_angles= [0, -8, 8, -16, 16]
@onready var node_indexes = [2, 1, 3, 0, 4]
@onready var flipped_node_indexes = [2, 3, 1, 4, 0]
var flower_nodes

func _ready():
	flower_nodes = get_children()

func add_flower(flower):
	for flower_node in flower_nodes:
		var child_flower = Helpers.get_only_child(flower_node)
		if not child_flower:
			Helpers.set_parent(flower, flower_node)
			flower.position = Vector2.ZERO
			flower.rotation_degrees = 0
			flower.set_pickup_height()
			return

func get_flowers():
	var flowers = []
	for flower_node in flower_nodes:
		var child_flower = Helpers.get_only_child(flower_node)
		if child_flower:
			flowers.append(child_flower)
	return flowers

func set_flip_h(val):
	for i in range(5):
		var child_flower = Helpers.get_only_child(flower_nodes[i])
		if child_flower:
			child_flower.set_flip_h(val)
		# face left
		if val:
			flower_nodes[i].position = node_positions[i]
			flower_nodes[i].position.x *= -1
			flower_nodes[i].rotation_degrees = node_angles[i]  * -1
			move_child(flower_nodes[i], flipped_node_indexes[i])
		# face right
		else:
			flower_nodes[i].position = node_positions[i]
			flower_nodes[i].rotation_degrees = node_angles[i]
			move_child(flower_nodes[i], node_indexes[i])

func tween_height(target: int, duration: float):
	for flower in get_flowers():
		flower.tween_height(target, duration)
