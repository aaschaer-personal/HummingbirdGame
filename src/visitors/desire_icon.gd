class_name DesireIcon extends Node2D

@onready var main_sprite = $MainSprite
@onready var petal_sprite = $PetalSprite

var main_texture = null
var petal_texture = null

func _ready():
	var species = get_tree().get_first_node_in_group("level").species
	main_texture = load("res://assets/UI/Icons/%s.png" % species)
	petal_texture = load("res://assets/UI/Icons/%s_petals.png" % species)

func set_icon(color):
	main_sprite.set_texture(main_texture)
	petal_sprite.set_texture(petal_texture)
	petal_sprite.modulate = color
