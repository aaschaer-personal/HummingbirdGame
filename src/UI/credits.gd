extends NinePatchRect

@onready var exit_button = $ExitButton

func _ready():
	exit_button.pressed.connect(close)
	
func close():
	visible = false
