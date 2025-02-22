extends CharacterBody2D

signal point_reached

var target_point = Vector2(0,0)
var speed = 200
var moving = false

func _process(delta):
	if global_position.distance_to(target_point) >= speed * delta:
		var direction = global_position.direction_to(target_point)
		velocity = direction * speed
		moving = true
		move_and_slide()
	else:
		velocity = Vector2(0,0)
		global_position = target_point
		if moving:
			moving = false
			point_reached.emit()
