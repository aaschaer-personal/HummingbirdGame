extends Node2D

@export var color = Color.WHITE
@onready var plant = $Plant
@onready var petals = $Petals

func _ready():
	petals.modulate = color
	visible = false

func play(animation):
	visible = true
	plant.play(animation)
	petals.play(animation)

func bloom_with_random_delay():
	var frames = randi() % 8
	await get_tree().create_timer(0.1 * frames).timeout
	play("bloom")
