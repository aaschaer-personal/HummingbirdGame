extends Control

@onready var flower = $Flower
@onready var petals = $Petals
@onready var label = $Label
@onready var sunflower_main = preload("res://assets/UI/Icons/sunflower.png")
@onready var sunflower_petals = preload("res://assets/UI/Icons/sunflower_petals.png")

func fill_sunflower(yellow):
	flower.texture = sunflower_main
	petals.texture = sunflower_petals
	petals.modulate = GenomeHelpers.sunflower_flower_color(yellow)
	if yellow == 0:
		label.text = "yy"
	elif yellow == 1:
		label.text = "Yy"
	elif yellow == 2:
		label.text = "YY"
	else:
		assert(false)
