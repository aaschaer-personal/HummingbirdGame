class_name VisitorSpawn extends Node2D

@export var left_to_right = true

var spawn_point
var landing_point
var visitor = null

func _ready():
	landing_point = $LandingPoint.global_position
	if left_to_right:
		spawn_point = $LeftSpawnPoint.global_position
	else:
		spawn_point = $RightSpawnPoint.global_position
