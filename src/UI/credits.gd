extends NinePatchRect

@onready var exit_button = $ExitButton

func _ready():
	exit_button.pressed.connect(close)
	
func _input(event):
	if event.is_action_released("exit_menu"):
		close()
	
func close():
	visible = false
