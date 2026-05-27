extends NinePatchRect

@onready var text = $Text
@onready var ok_button = $HBoxContainer/OkButton

func _ready():
	ok_button.pressed.connect(close)
	
func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false
