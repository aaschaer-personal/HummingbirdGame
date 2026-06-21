extends Sprite2D

var arrow_option_visible = false
var arrow_main_visible = false
var arrow_side_visible = false

func _ready():
	set_option_visibility(Config.get_option("show_tutorial"))
	var options = get_tree().get_first_node_in_group("options")
	options.show_tutorial_changed.connect(set_option_visibility)

func _fade_arrow(should_be_visible):
	if should_be_visible and (not visible):
		modulate = Color.TRANSPARENT
		visible = true
		var tween = create_tween()
		tween.tween_property(
			self, "modulate", Color.WHITE, .2
		)
	elif (not should_be_visible) and visible:
		modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(
			self, "modulate", Color.TRANSPARENT, .2
		)
		await tween.finished
		visible = false

func set_option_visibility(vis):
	arrow_option_visible = vis
	visible = arrow_option_visible and (arrow_main_visible or arrow_side_visible)

func set_main_visibility(vis):
	arrow_main_visible = vis
	_fade_arrow(arrow_option_visible and (arrow_main_visible or arrow_side_visible))

func set_side_visibility(vis):
	arrow_side_visible = vis
	_fade_arrow(arrow_option_visible and (arrow_main_visible or arrow_side_visible))
