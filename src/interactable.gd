class_name Interactable extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

func is_interactable():
	return true

func on_clicked(_point: Vector2):
	pass
