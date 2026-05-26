class_name Interactable extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")

var arrow
var arrow_option_visible = false
var arrow_main_visible = false
var arrow_side_visible = false

func _ready():
	if has_node("Arrow"):
		arrow = $Arrow
		set_arrow_option_visibility(Config.get_option("show_tutorial"))
		var options = get_tree().get_first_node_in_group("options")
		options.show_tutorial_changed.connect(set_arrow_option_visibility)

func is_interactable():
	return true

func get_player_interaction():
	pass
	
func get_interaction_target():
	return self

func get_player_interaction_area():
	return player.general_interaction_area

func get_interaction_area():
	return self

func get_interaction_point(_selection_point: Vector2):
	return get_interaction_area().global_position

func on_selected(_selection_point: Vector2):
	if is_interactable():
		player.set_interaction_target(
				get_player_interaction(),
				get_interaction_target(),
				get_player_interaction_area(),
				get_interaction_area(),
				get_interaction_point(_selection_point),
			)

func _fade_arrow(should_be_visible):
	if should_be_visible and (not arrow.visible):
		arrow.modulate = Color.TRANSPARENT
		arrow.visible = true
		var tween = create_tween()
		tween.tween_property(
			arrow, "modulate", Color.WHITE, .2
		)
	elif (not should_be_visible) and arrow.visible:
		arrow.modulate = Color.WHITE
		var tween = create_tween()
		tween.tween_property(
			arrow, "modulate", Color.TRANSPARENT, .2
		)
		await tween.finished
		arrow.visible = false

func set_arrow_main_visibility(vis):
	arrow_main_visible = vis
	_fade_arrow(arrow_option_visible and (arrow_main_visible or arrow_side_visible))

func set_arrow_side_visibility(vis):
	arrow_side_visible = vis
	_fade_arrow(arrow_option_visible and (arrow_main_visible or arrow_side_visible))

func set_arrow_option_visibility(vis):
	arrow_option_visible = vis
	arrow.visible = arrow_option_visible and (arrow_main_visible or arrow_side_visible)
