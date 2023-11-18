extends NinePatchRect

@onready var continue_button = $ContinueButton

func _ready():
	continue_button.pressed.connect(close)
	
func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false
