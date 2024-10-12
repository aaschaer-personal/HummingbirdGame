extends NinePatchRect

@onready var main_scene = preload("res://src/main.tscn")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_packed(main_scene)
