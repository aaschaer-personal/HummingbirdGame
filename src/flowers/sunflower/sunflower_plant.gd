class_name SunflowerPlant extends Plant

func _ready():
	flower_1_scene = preload("res://src/flowers/sunflower/sunflower_flower_1.tscn")
	flower_2_scene = preload("res://src/flowers/sunflower/sunflower_flower_2.tscn")
	flower_3_scene = preload("res://src/flowers/sunflower/sunflower_flower_3.tscn")
	super._ready()

func _rand_flower_positions():
	var positions = [1,2]
	positions.shuffle()
	positions.insert(0, 0)
	return positions
