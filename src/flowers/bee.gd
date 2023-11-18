class_name Bee extends AnimatedSprite2D

var hover_points: Array
var active = true

func _ready():
	hover_points = get_parent().get_node("BeeHoverPoints").get_children()
	fly_then_hover()

func fly_then_hover():
	if not active:
		return
	var point = hover_points.pick_random().position
	var tween = create_tween()
	tween.tween_property(self, "position", point, .4)
	await tween.finished
	hover_then_fly()

func hover_then_fly():
	var starting_position = position
	var options = [-1, 0, 1]
	for i in range(1 + randi() % 8):
		if not active:
			return
		var rand_offset = Vector2(options.pick_random(), options.pick_random())
		var tween = create_tween()
		tween.tween_property(
			self, "position", starting_position + rand_offset, .2
		)
		await tween.finished
	fly_then_hover()

func fly_away():
	active = false
	var flight_vector = Vector2(-10, -20)
	if bool(randi() % 2):
		flight_vector.x *= -1
	var duration = .4
	var tween1 = create_tween()
	tween1.tween_property(self, "position", position + flight_vector, duration)
	var tween2 = create_tween()
	tween2.tween_property(self, "modulate", Color.TRANSPARENT, duration)
	await tween2.finished
	queue_free()
