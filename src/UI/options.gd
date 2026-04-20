extends NinePatchRect

signal volume_changed
signal controls_changed

@onready var confirm_button = $ConfirmButton
@onready var music_volume = $ScrollContainer/VBoxContainer/MusicVolume/HSlider
@onready var effects_volume = $ScrollContainer/VBoxContainer/EffectsVolume/HSlider
@onready var show_tutorial = $ScrollContainer/VBoxContainer/ShowTutorial/CheckBox
@onready var quick_start = $ScrollContainer/VBoxContainer/QuickStart/CheckBox
@onready var controls = $ScrollContainer/VBoxContainer/Controls
@onready var exit_button = $ExitButton

var control_awaiting_input = null
var ignore_next_exit = false
var ignore_next_pause = false
var config

func _ready():
	config = Config.get_config()
	music_volume.value = config.get_value("options", "music_volume", 50)
	effects_volume.value = config.get_value("options", "effects_volume", 50)
	show_tutorial.button_pressed = config.get_value("options", "show_tutorial", true)
	quick_start.button_pressed = config.get_value("options", "quick_start", false)

	for action in config.get_section_keys("controls"):
		var event = config.get_value("controls", action, null)
		if event:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			controls_changed.emit(action, event)

	music_volume.value_changed.connect(emit_music_volume_changed)
	effects_volume.value_changed.connect(emit_effects_volume_changed)
	confirm_button.pressed.connect(confirm)
	exit_button.pressed.connect(close)
	for control in controls.get_children():
		control.key_button.pressed.connect(control_pressed.bind(control))

func confirm():
	config.set_value("options", "music_volume", music_volume.value)
	config.set_value("options", "effects_volume", effects_volume.value)
	config.set_value("options", "show_tutorial", show_tutorial.button_pressed)
	config.set_value("options", "quick_start", quick_start.button_pressed)
	Config.save_config()
	close()

func control_pressed(control):
	control_awaiting_input = control
	control.set_key_label("(input)")

func emit_music_volume_changed(value):
	volume_changed.emit("music_volume",value)
	
func emit_effects_volume_changed(value):
	volume_changed.emit("effects_volume", value)

func close():
	visible = false

func _input(event):
	if control_awaiting_input:
		# ignore mouse movement
		if event is InputEventMouseMotion:
			pass
		# map anything that can be mapped other than mouse press
		elif event.is_action_type() and not event is InputEventMouseButton:
			var action = control_awaiting_input.name
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			control_awaiting_input.set_key_label()
			control_awaiting_input = null
			config.set_value("controls", action, event)
			controls_changed.emit(action, event)
			# don't exit/unpause from releasing the new button
			if action == "exit_menu":
				ignore_next_exit = true
			if action == "pause":
				ignore_next_pause = true
		# reset on an any other inputs
		else:
			control_awaiting_input.set_key_label()
			control_awaiting_input = null

	# close if not being controlled by level input_logic
	elif event.is_action_released("exit_menu"):
		if not get_parent() is PauseScreen:
			if ignore_next_exit:
				ignore_next_exit = false
			else:
				close()
