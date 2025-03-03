class_name Visitor extends Interactable

@export var species: String
@onready var sprite = $MainSprite
@onready var speech_bubble_sprite = $SpeechBubbleSprite
@onready var desire_icons = $SpeechBubbleSprite/DesireIconHolder
@onready var hold_point = $HoldPoint
@onready var acceptance_area = $AcceptanceArea
@onready var shadow_generator = $MainSprite/ShadowGenerator
@onready var desired_bouquet_colors: Array
@onready var audio_player = $OptionAwareAudioPlayer
@onready var collision_shape = $Collision/CollisionShape2D
@onready var bouquet_scene = preload("res://src/items/bouquet.tscn")
@onready var visitor_landing_sound = preload("res://assets/Sounds/visitor_landing.wav")
var birdsong = null

var off_screen_height = 300
var visitor_bouquet
var spawn = null

func _ready():
	birdsong = load("res://assets/Sounds/%s.wav" % species)
	
	visitor_bouquet = bouquet_scene.instantiate()
	hold_point.add_child(visitor_bouquet)

func flip():
	sprite.flip_h = true
	speech_bubble_sprite.flip_h = true
	for child in get_children():
		child.position.x *= -1

func land(visitor_spawn: VisitorSpawn):
	spawn = visitor_spawn
	if not spawn.left_to_right:
		flip()

	global_position = spawn.spawn_point
	audio_player.stream = visitor_landing_sound
	audio_player.play()

	sprite.play("landing")
	var position_tween = create_tween()
	var height_tween = create_tween()
	position_tween.tween_property(
		self,
		"global_position",
		spawn.landing_point,
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
	collision_shape.disabled = false
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
		visitor_bouquet.set_flip_h(not spawn.left_to_right)
	if not flowers_given:
		speech_bubble_sprite.visible = false
		sprite.play("confused")
		await sprite.animation_finished
		sprite.play("idle")
		speech_bubble_sprite.visible = true

	if len(desired_bouquet_colors) == 0:
		get_parent().finish_bouquet()
		speech_bubble_sprite.visible = false
		emote_and_take_off()

func emote_and_take_off():
	audio_player.stream = birdsong
	audio_player.play()
	sprite.play("happy")
	await sprite.animation_finished

	collision_shape.disabled = true
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
	spawn.visitor = null
	get_parent().on_visitor_left(self)
	queue_free()
