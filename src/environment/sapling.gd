class_name Sapling extends Interactable

@onready var perch_zone = $PerchZone
@onready var top_rustle_zone = $TopRustleZone
@onready var bottom_rustle_zone = $BottomRustleZone
@onready var sprite = $AnimatedSprite2D
@export var is_horizontal = true

func _ready():
	top_rustle_zone.body_entered.connect(top_rustle)
	bottom_rustle_zone.body_entered.connect(bottom_rustle)

func is_interactable():
	return player.held_item == null

func get_interaction_target():
	return perch_zone

func get_player_interaction():
	return "start_perch_h"

func get_player_interaction_area():
	return player.landing_area
	
func get_interaction_area():
	return perch_zone

func rustle():
	sprite.play("full_rustle")

func top_rustle(_body):
	sprite.play("top_rustle")

func bottom_rustle(_body):
	sprite.play("bottom_rustle")
