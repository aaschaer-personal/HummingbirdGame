class_name LupinePlant extends Plant

func _ready():
	flower_1_scene = preload("res://src/flowers/lupine/lupine_flower_1.tscn")
	flower_2_scene = preload("res://src/flowers/lupine/lupine_flower_2.tscn")
	flower_3_scene = preload("res://src/flowers/lupine/lupine_flower_3.tscn")
	super._ready()
