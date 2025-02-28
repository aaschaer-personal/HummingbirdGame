extends Node2D

@export var object_height = 0
@export var height_off_ground = 0
@export var offset_rotation = false
@onready var shadow_canvas_group = get_tree().get_first_node_in_group("shadow_canvas_group")
var parent
var shadow

func _ready():
	parent = get_parent()
	if parent is Sprite2D:
		shadow = Sprite2D.new()
		shadow.texture = parent.texture
	elif parent is AnimatedSprite2D:
		shadow = AnimatedSprite2D.new()
		shadow.sprite_frames = parent.sprite_frames
		parent.frame_changed.connect(play_parent_animation)
		play_parent_animation()
	else:
		assert(false)
	parent.visibility_changed.connect(set_visibility)
	set_visibility()
	shadow_canvas_group.add_child(shadow)
	shadow.scale.y = parent.scale.y * -.5

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if shadow != null:
			shadow.queue_free()

func _process(_delta):
	# offset height if rotated, mostly just for bouquets
	var rotation_offset = 0
	if offset_rotation:
		if shadow.flip_h:
			rotation_offset = global_rotation_degrees / 1.5
		else:
			rotation_offset = -global_rotation_degrees / 1.5

	shadow.global_position.x = parent.global_position.x
	shadow.global_position.y = (
		parent.global_position.y +
		(object_height * 3.0/4.0) +
		(height_off_ground * 2) +
		rotation_offset
	)
	shadow.flip_v = parent.flip_v
	shadow.flip_h = parent.flip_h
	shadow.rotation_degrees = -parent.global_rotation_degrees

func play_parent_animation():
	shadow.play(parent.animation)
	shadow.set_frame_and_progress(parent.frame, parent.frame_progress)

func set_visibility():
	shadow.visible = parent.visible
