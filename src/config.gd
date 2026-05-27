extends Node

var config
var path = "user://gamedata.cfg"

var defaults = {
	"music_volume": 50,
	"effects_volume": 50,
	"show_tutorial": true,
	"skip_intros": false,
	"label_colors": false,
	"show_genes": false,
	"disable_bees": false,
	"energy_loss": 1.0,
}

func get_option(value: String):
	config = get_config()
	return config.get_value("options", value, defaults[value])

func get_config():
	if not config:
		config = ConfigFile.new()
		config.load(path)
	return config

func save_config():
	get_config().save(path)
