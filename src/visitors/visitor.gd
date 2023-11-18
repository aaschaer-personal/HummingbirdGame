class_name Visitor extends Interactable

@onready var sprite = $MainSprite
@onready var speech_bubble_sprite = $SpeechBubbleSprite
@onready var desire_icons = $SpeechBubbleSprite/DesireIconHolder
@onready var hold_point = $HoldPoint
@onready var acceptance_area = $AcceptanceArea
@onready var shadow_generator = $MainSprite/ShadowGenerator
@onready var desired_bouquet_colors: Array

var off_screen_height = 300

func land(landing_point: Node2D):
	sprite.play("landing")
	var position_tween = create_tween()
	var height_tween = create_tween()
	position_tween.tween_property(
		self,
		"position",
		landing_point.position,
		10.0/10.0
	)
	shadow_generator.height_off_ground = off_screen_height
	height_tween.tween_property(
		shadow_generator,
		"height_off_ground",
		12,
		10.0/10.0
	)
	await sprite.animation_finished
	sprite.play("idle")
	show_desires()

func show_desires():
	speech_bubble_sprite.visible = true
	
	for i in desired_bouquet_colors.size():
		var desired_color = desired_bouquet_colors[i]
		desire_icons.get_children()[i].set_icon(
			get_parent().species, desired_color)

func is_interactable():
	return player.held_item is Bouquet

func get_player_interaction():
	return "give_bouquet"

func get_interaction_area():
	return acceptance_area

func give_bouquet(bouquet: Bouquet):
	speech_bubble_sprite.visible = false
	bouquet.reparent(hold_point)
	bouquet.global_position = hold_point.global_position
	bouquet.set_flip_h(false)
	bouquet.tween_height(13, 0)
	
	var bouquet_matched = get_parent().evaluate_bouquet(
		bouquet, desired_bouquet_colors)
	emote_and_take_off(bouquet_matched)

func emote_and_take_off(bouquet_matched):
	if bouquet_matched:
		sprite.play("happy")
	else:
		sprite.play("confused")
	await sprite.animation_finished

	sprite.play_backwards("landing")
	var position_tween = create_tween()
	var height_tween = create_tween()
	var duration = 1.0
	position_tween.tween_property(
		self,
		"position",
		position - Vector2(0, off_screen_height),
		duration
	)
	height_tween.tween_property(
		shadow_generator,
		"height_off_ground",
		off_screen_height,
		duration
	)
	var bouquet = Helpers.get_only_child(hold_point)
	bouquet.tween_height(off_screen_height, duration)
	await sprite.animation_finished
	get_parent().on_visitor_left()
	queue_free()
