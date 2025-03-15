extends NinePatchRect

@onready var exit_button = $ExitButton

func _ready():
	exit_button.pressed.connect(close)
	
func _input(event):
	if event.is_action_released("Esc"):
		close()
	
func close():
	visible = false
