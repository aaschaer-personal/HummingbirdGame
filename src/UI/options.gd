extends NinePatchRect

signal volume_changed

@onready var confirm_button = $ConfirmButton
@onready var music_volume = $VBoxContainer/MusicVolume/HSlider
@onready var effects_volume = $VBoxContainer/EffectsVolume/HSlider
@onready var show_tutorial = $VBoxContainer/ShowTutorial/CheckBox
@onready var quick_start = $VBoxContainer/QuickStart/CheckBox

var config

func _ready():
	config = Config.get_config()
	music_volume.value = config.get_value("options", "music_volume", 50)
	effects_volume.value = config.get_value("options", "effects_volume", 50)
	show_tutorial.button_pressed = config.get_value("options", "show_tutorial", true)
	quick_start.button_pressed = config.get_value("options", "quick_start", false)
	music_volume.value_changed.connect(emit_music_volume_changed)
	effects_volume.value_changed.connect(emit_effects_volume_changed)
	confirm_button.pressed.connect(confirm)

func confirm():
	config.set_value("options", "music_volume", music_volume.value)
	config.set_value("options", "effects_volume", effects_volume.value)
	config.set_value("options", "show_tutorial", show_tutorial.button_pressed)
	config.set_value("options", "quick_start", quick_start.button_pressed)
	Config.save_config()
	visible = false

func emit_music_volume_changed(value):
	volume_changed.emit("music_volume",value)
	
func emit_effects_volume_changed(value):
	volume_changed.emit("effects_volume", value)
