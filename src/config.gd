extends Node

var config
var path = "user://gamedata.cfg"

func get_config():
	if not config:
		config = ConfigFile.new()
		config.load(path)
	return config

func save_config():
	config.save(path)
