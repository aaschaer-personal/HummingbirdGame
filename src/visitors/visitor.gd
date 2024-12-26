class_name Visitor extends Interactable

@onready var sprite = $MainSprite
@onready var speech_bubble_sprite = $SpeechBubbleSprite
@onready var desire_icons = $SpeechBubbleSprite/DesireIconHolder
@onready var hold_point = $HoldPoint
@onready var acceptance_area = $AcceptanceArea
@onready var shadow_generator = $MainSprite/ShadowGenerator
@onready var desired_bouquet_colors: Array
@onready var audio_player = $OptionAwareAudioPlayer
@onready var bouquet_scene = preload("res://src/items/bouquet.tscn")
@onready var visitor_landing_sound = preload("res://assets/Sounds/visitor_landing.wav")
@onready var house_finch_sound = preload("res://assets/Sounds/house_finch.wav")

var off_screen_height = 300
var visitor_bouquet

func _ready():
	visitor_bouquet = bouquet_scene.instantiate()
	hold_point.add_child(visitor_bouquet)
	# bouquet.tween_height(13, 0)

func land(landing_point: Node2D):
	audio_player.stream = visitor_landing_sound
	audio_player.play()

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
		desire_icons.get_children()[i].set_icon(desired_color)
func is_interactable():
	return player.held_item is Bouquet

func get_player_interaction():
	return "give_bouquet"

func get_interaction_area():
	return acceptance_area

func give_bouquet(given_bouquet: Bouquet):
	var flowers_given = 0
	
	for flower in given_bouquet.get_flowers():
		for desired_color in desired_bouquet_colors:
			if flower.color == desired_color:
				visitor_bouquet.add_flower(flower)
				desired_bouquet_colors.erase(desired_color)
				flowers_given += 1
				break

	if flowers_given:
		visitor_bouquet.set_flip_h(false)
	else:
		speech_bubble_sprite.visible = false
		sprite.play("confused")
		await sprite.animation_finished
		speech_bubble_sprite.visible = true

	if len(desired_bouquet_colors) == 0:
		get_parent().finish_bouquet()
		speech_bubble_sprite.visible = false
		emote_and_take_off()

func emote_and_take_off():
	audio_player.stream = house_finch_sound
	audio_player.play()
	sprite.play("happy")
	await sprite.animation_finished

	audio_player.stream = visitor_landing_sound
	audio_player.play()
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
