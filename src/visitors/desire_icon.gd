class_name DesireIcon extends Node2D

@onready var main_sprite = $MainSprite
@onready var petal_sprite = $PetalSprite

@onready var sunflower_main = preload("res://assets/UI/Icons/sunflower.png")
@onready var sunflower_petal = preload("res://assets/UI/Icons/sunflower_petals.png")

@onready var lupine_main = preload("res://assets/UI/Icons/lupine.png")
@onready var lupine_petal = preload("res://assets/UI/Icons/lupine_petals.png")

func set_icon(species, color):
	if species == "Sunflower":
		main_sprite.set_texture(sunflower_main)
		petal_sprite.set_texture(sunflower_petal)
	elif species == "Lupine":
		main_sprite.set_texture(lupine_main)
		petal_sprite.set_texture(lupine_petal)
	else:
		assert(false)
	
	petal_sprite.modulate = color
