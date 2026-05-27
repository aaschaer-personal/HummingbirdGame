extends NinePatchRect

signal volume_changed
signal show_tutorial_changed
signal label_colors_changed
signal show_genes_changed
signal disable_bees_changed
signal energy_loss_changed
signal controls_changed

@onready var confirm_button = $ConfirmButton
@onready var music_volume = $ScrollContainer/VBoxContainer/MusicVolume/HSlider
@onready var effects_volume = $ScrollContainer/VBoxContainer/EffectsVolume/HSlider
@onready var show_tutorial = $ScrollContainer/VBoxContainer/ShowTutorial/CheckBox
@onready var skip_intros = $ScrollContainer/VBoxContainer/SkipIntros/CheckBox
@onready var label_colors = $ScrollContainer/VBoxContainer/LabelColors/CheckBox
@onready var show_genes = $ScrollContainer/VBoxContainer/ShowGenes/CheckBox
@onready var disable_bees = $ScrollContainer/VBoxContainer/DisableBees/CheckBox
@onready var energy_loss = $ScrollContainer/VBoxContainer/EnergyLoss/HSlider
@onready var controls = $ScrollContainer/VBoxContainer/Controls
@onready var exit_button = $ExitButton
@onready var reset_defaults_button = $ScrollContainer/VBoxContainer/ResetDefaultsButton

var control_awaiting_input = null
var ignore_next_exit = false
var ignore_next_pause = false
var config

func _ready():
	music_volume.value = Config.get_option("music_volume")
	effects_volume.value = Config.get_option("effects_volume")
	show_tutorial.button_pressed = Config.get_option("show_tutorial")
	skip_intros.button_pressed = Config.get_option("skip_intros")
	label_colors.button_pressed = Config.get_option("label_colors")
	show_genes.button_pressed = Config.get_option("show_genes")
	disable_bees.button_pressed = Config.get_option("disable_bees")
	energy_loss.value = Config.get_option("energy_loss") * 50

	config = Config.get_config()
	for action in config.get_section_keys("controls"):
		var event = config.get_value("controls", action, null)
		if event:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			controls_changed.emit(action, event)

	music_volume.value_changed.connect(emit_music_volume_changed)
	effects_volume.value_changed.connect(emit_effects_volume_changed)
	label_colors.toggled.connect(label_colors_changed.emit)
	show_genes.toggled.connect(show_genes_changed.emit)
	show_tutorial.toggled.connect(show_tutorial_changed.emit)
	disable_bees.toggled.connect(disable_bees_changed.emit)

	reset_defaults_button.pressed.connect(reset_defaults)
	confirm_button.pressed.connect(confirm)
	exit_button.pressed.connect(close)
	for control in controls.get_children():
		control.key_button.pressed.connect(control_pressed.bind(control))

func confirm():
	config.set_value("options", "music_volume", music_volume.value)
	config.set_value("options", "effects_volume", effects_volume.value)
	config.set_value("options", "show_tutorial", show_tutorial.button_pressed)
	config.set_value("options", "skip_intros", skip_intros.button_pressed)
	config.set_value("options", "label_colors", label_colors.button_pressed)
	config.set_value("options", "show_genes", show_genes.button_pressed)
	config.set_value("options", "disable_bees", disable_bees.button_pressed)
	config.set_value("options", "energy_loss", energy_loss.value / 50.0)
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
	# signal with the config value in case nothing was saved
	volume_changed.emit("music_volume", Config.get_option("music_volume"))
	volume_changed.emit("effects_volume", Config.get_option("effects_volume"))
	show_tutorial_changed.emit(Config.get_option("show_tutorial"))
	label_colors_changed.emit(Config.get_option("label_colors"))
	show_genes_changed.emit(Config.get_option("show_genes"))
	disable_bees_changed.emit(Config.get_option("disable_bees"))
	energy_loss_changed.emit(Config.get_option("energy_loss"))
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

func reset_defaults():
	music_volume.value = Config.defaults["music_volume"]
	effects_volume.value = Config.defaults["effects_volume"]
	show_tutorial.button_pressed = Config.defaults["show_tutorial"]
	skip_intros.button_pressed = Config.defaults["skip_intros"]
	label_colors.button_pressed = Config.defaults["label_colors"]
	show_genes.button_pressed = Config.defaults["show_genes"]
	disable_bees.button_pressed = Config.defaults["disable_bees"]
	energy_loss.value = Config.defaults["energy_loss"] * 50
	InputMap.load_from_project_settings()

	emit_music_volume_changed(Config.defaults["music_volume"])
	emit_effects_volume_changed(Config.defaults["effects_volume"])
	show_tutorial_changed.emit(Config.defaults["show_tutorial"])
	label_colors_changed.emit(Config.defaults["label_colors"])
	show_genes_changed.emit(Config.defaults["show_genes"])
	disable_bees_changed.emit(Config.defaults["disable_bees"])
	energy_loss_changed.emit(Config.defaults["energy_loss"])
	for control in controls.get_children():
		var action = control.name
		var event = InputMap.action_get_events(action)[0]
		controls_changed.emit(action, event)
