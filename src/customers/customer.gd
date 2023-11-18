class_name Customer extends Interactable

@onready var sprite = $MainSprite
@onready var speech_bubble_sprite = $SpeechBubbleSprite
@onready var desire_icons = $SpeechBubbleSprite/DesireIconHolder
@onready var hold_point = $HoldPoint
@onready var acceptance_area = $AcceptanceArea
@onready var desired_bouquet: Array


func land(landing_point: Node2D):
	sprite.play("landing")
	var tween = create_tween()
	tween.tween_property(
		self,
		"position",
		landing_point.position,
		10.0/10.0
	)
	await sprite.animation_finished
	sprite.play("idle")
	show_desires()

func show_desires():
	speech_bubble_sprite.visible = true
	
	for i in desired_bouquet.size():
		var desired_icon = desired_bouquet[i]
		desire_icons.get_children()[i].set_icon(desired_icon)

func is_interactable():
	return player.held_item is Bouquet

func on_clicked(_point: Vector2):
	if is_interactable():
		player.set_interaction_target(
			"sell_bouquet",
			self,
			player.general_interaction_area,
			acceptance_area,
			acceptance_area.global_position
		)

func give_bouquet(bouquet: Bouquet):
	speech_bubble_sprite.visible = false
	bouquet.reparent(hold_point)
	bouquet.global_position = hold_point.global_position
	bouquet.set_flip_h(false)
	var points_dict = evaluate_bouquet(bouquet)
	GameProgression.process_bouquet(bouquet)
	GameProgression.add_points(points_dict)
	emote_and_take_off(points_dict)

func evaluate_bouquet(bouquet: Bouquet):
	var flowers = bouquet.get_flowers()
	var desired_size = desired_bouquet.size()
	var accuracy = 0
	var difficulty = 0
	var time = 0
	var matched = []
	
	# first handle exact matches
	for flower in flowers:
		for desired_flower in desired_bouquet:
			if (desired_flower["species"] == flower.species
				and desired_flower["color"] == flower.color):
					accuracy += 10.0 / desired_size
					difficulty += desired_flower["difficulty"]
					matched.append(flower)
					desired_bouquet.erase(desired_flower)
					break
	for matched_flower in matched:
		flowers.erase(matched_flower)
	matched = []
	
	# then partial matches
	for flower in flowers:
		for desired_flower in desired_bouquet:
			# TODO: more robust partial match function
			if (desired_flower["species"] == flower.species
				or desired_flower["color"] == flower.color):
					accuracy += 2.0 / desired_size
					matched.append(flower)
					desired_bouquet.erase(desired_flower)
					break
	for matched_flower in matched:
		flowers.erase(matched_flower)
	matched = []

	# penalty for missing flowers
	accuracy -= desired_bouquet.size() * 10.0 / desired_size

	return {
		"accuracy": round(accuracy),
		"difficulty": round(difficulty),
		"time": round(time),
	}

func emote_and_take_off(points_dict: Dictionary):
	if points_dict["accuracy"] == 10:
		sprite.play("happy")
	else:
		sprite.play("confused")
	await sprite.animation_finished

	sprite.play_backwards("landing")
	var tween = create_tween()
	tween.tween_property(
		self,
		"position",
		position + Vector2(0, -300),
		10.0/10.0
	)
	await sprite.animation_finished
	get_parent().wait_for_next_customer()
	queue_free()
