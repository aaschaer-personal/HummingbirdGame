class_name CutFlower extends Item

@onready var petal_sprite = $PetalSprite
@onready var collision_shape = $CollisionShape2D
@onready var decay_timer = $DecayTimer
@export var species: String
var collision_y = -12
var color: Color
var is_decaying = false

func _ready():
	decay_timer.timeout.connect(decay)
	start_decay_timer()
	
	# fall over, starting from vertical
	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation_degrees",
		90,
		.1,
	)

func is_interactable():
	return (
		not is_decaying and player.held_item == null 
		or (
			player.held_item is Bouquet
			and player.held_item.get_flowers().size() < 5
		)
	)

func set_color(new_color: Color):
	petal_sprite.modulate = new_color
	color = new_color

func set_flip_h(val: bool):
	# since we are rotated 90 degrees, flip v instead
	sprite.flip_v = val
	petal_sprite.flip_v = val
	if val:
		collision_shape.position.y = collision_y * -1
	else:
		collision_shape.position.y = collision_y

func start_decay_timer():
	decay_timer.start(10)

func decay():
	is_decaying = true
	sprite.play("decay")
	petal_sprite.play("decay")
	await sprite.animation_finished
	queue_free()
