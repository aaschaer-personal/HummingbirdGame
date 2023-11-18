class_name DesireIcon extends Node2D

@onready var main_sprite = $MainSprite
@onready var petal_sprite = $PetalSprite
@onready var lupine_main = preload("res://assets/Customers/Icons/lupine.png")
@onready var lupine_petal = preload("res://assets/Customers/Icons/lupine_petals.png")

func set_icon(icon_dict):
	if icon_dict["species"] == "Lupine":
		main_sprite.set_texture(lupine_main)
		petal_sprite.set_texture(lupine_petal)
	
	petal_sprite.modulate = icon_dict["color"]
