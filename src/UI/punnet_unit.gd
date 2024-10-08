extends Control

@onready var flower = $Flower
@onready var petals = $Petals
@onready var label = $Label
@onready var sunflower_main = preload("res://assets/UI/Icons/sunflower.png")
@onready var sunflower_petals = preload("res://assets/UI/Icons/sunflower_petals.png")

func fill_sunflower(color):
	flower.texture = sunflower_main
	petals.texture = sunflower_petals
	petals.modulate = GenomeHelpers.sunflower_flower_color(color)
	if color == 0:
		label.text = "YY"
	elif color == 1:
		label.text = "RY"
	elif color == 2:
		label.text = "RR"
	else:
		assert(false)
