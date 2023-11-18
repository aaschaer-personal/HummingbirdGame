extends NinePatchRect

@onready var retry_button = $RetryButton

func _ready():
	retry_button.pressed.connect(retry)
	
func open():
	get_tree().paused = true
	visible = true

func retry():
	get_tree().paused = false
	get_tree().reload_current_scene()
