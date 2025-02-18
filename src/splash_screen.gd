extends NinePatchRect

@onready var main_menu = preload("res://src/main_menu.tscn")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_packed(main_menu)
