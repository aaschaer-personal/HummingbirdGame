class_name DesireIcon extends Control

@onready var main_sprite = $MainSprite
@onready var petal_sprite = $PetalSprite
@onready var check_sprite = $CheckSprite

func set_texture_and_color(main_texture, petal_texture, color):
	main_sprite.set_texture(main_texture)
	petal_sprite.set_texture(petal_texture)
	petal_sprite.modulate = color
