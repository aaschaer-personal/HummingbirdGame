class_name CutFlower extends Item

@onready var petal_sprite = $PetalSprite
@onready var petal_shadow = $PetalSprite/ShadowGenerator
@onready var collision_shape = $CollisionShape2D
@onready var decay_timer = $DecayTimer
@export var species: String

var x_offset_by_species = {
	"sunflower": 12,
	"jewelweed": 6,
	"lupine": 14,
	"zinnia": 8,
}
# height, duration
var decay_data_by_species = {
	"sunflower": [4, .6],
	"jewelweed": [4, .4],
	"lupine": [1, .3],
	"zinnia": [2, .6],
}
var color: Color
var is_decaying = false

func _ready():
	add_to_group("cut_flowers")
	decay_timer.timeout.connect(decay)
	start_decay_timer()
	
	# fall over, starting from vertical
	rotation_degrees = -90
	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation_degrees",
		0,
		.1,
	)

func is_in_play():
	# for level_manager._failure_check
	if is_decaying:
		return false
	elif get_parent() is Level:
		return true
	elif get_parent().get_parent().get_parent().get_parent() is Visitor:
		return false
	return true

func is_interactable():
	if is_decaying or !get_parent() is Level:
		return false

	return player.held_item == null or (
		player.held_item is Bouquet
		and player.held_item.get_flowers().size() < 5
	)

func set_color(new_color: Color):
	petal_sprite.modulate = new_color
	color = new_color

func set_flip_h(val: bool):
	item_sprite.set_flip_h(val)
	petal_sprite.set_flip_h(val)
	var x_offset = x_offset_by_species[species]
	if val:
		item_sprite.position.x = x_offset * -1
		petal_sprite.position.x = x_offset * -1
		collision_shape.position.x = x_offset * -1
	else:
		item_sprite.position.x = x_offset
		petal_sprite.position.x = x_offset
		collision_shape.position.x = x_offset

func set_pickup_height():
	item_shadow.height_off_ground = pickup_height
	petal_shadow.height_off_ground = pickup_height

func drop():
	super()
	var angle_tween = create_tween()
	angle_tween.tween_property(
		self,
		"rotation_degrees",
		0,
		drop_duration,
	)

func tween_height(target: int, duration: float):
	super(target, duration)
	var petal_tween = create_tween()
	petal_tween.tween_property(
		petal_shadow,
		"height_off_ground",
		target,
		duration,
	)

func start_decay_timer():
	decay_timer.start(15)

func decay():
	is_decaying = true
	item_sprite.play("decay")
	petal_sprite.play("decay")
	var data = decay_data_by_species[species]
	tween_height(data[0], data[1])
	await item_sprite.animation_finished
	SignalBus.cut_flower_decayed.emit()
	queue_free()
