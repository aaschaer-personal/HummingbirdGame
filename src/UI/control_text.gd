extends RichTextLabel

@onready var options = get_tree().get_first_node_in_group("options")

var template
var actions = []

func _ready():
	options.controls_changed.connect(_on_controls_changed)
	if not template:
		template = text
		parse_actions()
		fill()

func parse_actions():
	actions = []
	for action in InputMap.get_actions():
		if "%" + action in template:
			actions.append(action)

func set_template(new_template: String):
	template = new_template
	parse_actions()
	fill()

func fill():
	text = template
	for action in actions:
		text = text.replace("%" + action, Helpers.get_action_event_name(action))

func fade_in():
	modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(
		self, "modulate", Color.WHITE, .2
	)
	await tween.finished

func fade_out():
	var tween = create_tween()
	tween.tween_property(
		self, "modulate", Color.TRANSPARENT, .2
	)
	await tween.finished
	queue_free()

func handle_guide_controls():
	# special handling for guide text that changes if pause and exit menu
	# no longer share the same action (both default to Esc)
	var same_text = "* Press %pause to pause, unpause, and exit menus."
	var diferent_text = """* Press %pause to pause and unpause.

* Press %exit_menu to exit menus."""
	if Helpers.get_action_event_name("pause") == Helpers.get_action_event_name("exit_menu"):
		template = template.replace(diferent_text, same_text)
	else:
		template = template.replace(same_text, diferent_text)
	parse_actions()

func _on_controls_changed(action, _event):
	if action in ["pause", "exit_menu"]:
		handle_guide_controls()
	if action in actions:
		fill()
