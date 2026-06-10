extends HSplitContainer

@onready var action_label = $ActionLabel
@onready var key_button = $KeyButton
@onready var options = get_tree().get_first_node_in_group("options")

func _ready():
	action_label.text = name.capitalize()
	if len(action_label.text) > 10:
		action_label.text = action_label.text.replace(" ", "\n")
	set_key_label()
	options.controls_changed.connect(_on_controls_changed)

func set_key_label(label=null):
	if not label:
		label = Helpers.get_action_event_name(name).replace(" ", "\n")
	key_button.text = label

func _on_controls_changed(action, event):
	if action == self.name:
		var label = Helpers.get_event_name(event)
		set_key_label(label)
