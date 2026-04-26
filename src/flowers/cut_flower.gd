class_name CutFlower extends Item

@onready var petal_sprite = $PetalSprite
@onready var petal_shadow = $PetalSprite/ShadowGenerator
@onready var collision_shape = $CollisionShape2D
@onready var decay_timer = $DecayTimer
@onready var color_label = $ColorLabel
@export var species: String

var x_offset_by_species = {
	"sunflower": 12,
	"jewelweed": 6,
	"lupine": 14,
	"zinnia": 8,
	"hibiscus": 10,
	"orchid": 10,
}
# height, duration
var decay_data_by_species = {
	"sunflower": [4, .6],
	"jewelweed": [4, .4],
	"lupine": [1, .3],
	"zinnia": [2, .6],
	"hibiscus": [4, .7],
	"orchid": [6, .7],
}
var color: Color
var is_decaying = false

func _ready():
	add_to_group("cut_flowers")
	decay_timer.timeout.connect(decay)
	var options = get_tree().get_first_node_in_group("options")
	options.label_colors_changed.connect(_on_label_colors_changed)
	start_decay_timer()
	fall_over()

func fall_over():
	# fall over, starting from vertical
	rotation_degrees = -90
	var tween = create_tween()
	tween.tween_property(
		self,
		"rotation_degrees",
		0,
		.1,
	)
	await tween.finished
	color_label.visible = Config.get_option("label_colors")

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
	color_label.text = Colors.color_name(new_color)

func set_flip_h(val: bool):
	item_sprite.set_flip_h(val)
	petal_sprite.set_flip_h(val)
	var x_offset = x_offset_by_species[species]
	if val:
		item_sprite.position.x = x_offset * -1
		petal_sprite.position.x = x_offset * -1
		collision_shape.position.x = x_offset * -1
		color_label.position.x = -40
	else:
		item_sprite.position.x = x_offset
		petal_sprite.position.x = x_offset
		collision_shape.position.x = x_offset
		color_label.position.x = 0

func set_pickup_height():
	item_shadow.height_off_ground = pickup_height
	petal_shadow.height_off_ground = pickup_height

func drop():
	super()
	color_label.visible = Config.get_option("label_colors")
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
	color_label.visible = false
	item_sprite.play("decay")
	petal_sprite.play("decay")
	var data = decay_data_by_species[species]
	tween_height(data[0], data[1])
	await item_sprite.animation_finished
	SignalBus.cut_flower_decayed.emit()
	queue_free()

func sync_shadow_position():
	var item_shadow_generator = $Item/ShadowGenerator
	var petal_shadow_generator = $PetalSprite/ShadowGenerator
	item_shadow_generator.sync_position()
	petal_shadow_generator.sync_position()

func _on_label_colors_changed(toggle_value):
	if is_interactable():
		color_label.visible = toggle_value
