extends NinePatchRect

@onready var button = $VBoxContainer/Button

func _ready():
	button.pressed.connect(close)
	
func open():
	get_tree().paused = true
	visible = true

func close():
	visible = false
	get_tree().paused = false
