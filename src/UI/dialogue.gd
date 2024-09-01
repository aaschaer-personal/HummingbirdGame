extends NinePatchRect

# true for yes, false for no
signal yes_no(yes: bool)

@onready var ok_button = $OKButton
@onready var yes_button = $YesButton
@onready var no_button = $NoButton
@onready var dialogue_text = $DialogueText
@onready var visuals_container = $VisualsContainer
@onready var punnet_square = $VisualsContainer/PunnetSquare
@onready var extra_space: int = 0

@onready var queue = []

func _ready():
	ok_button.pressed.connect(close)
	yes_button.pressed.connect(on_yes_pressed)
	no_button.pressed.connect(on_no_pressed)

func open(lines, yn_mode=false):
	if visible:
		queue.append({
			"lines": lines,
			"yn_mode": yn_mode,
		})
		return

	get_tree().paused = true
	ok_button.visible = !yn_mode
	yes_button.visible = yn_mode
	no_button.visible = yn_mode
	dialogue_text.text = " ".join(PackedStringArray(lines))
	size = Vector2(320, 180 + extra_space)
	global_position = Vector2(160, 90 - int(extra_space / 2.0))
	ok_button.position = Vector2(140, 140 + extra_space)
	yes_button.position = Vector2(56, 140 + extra_space)
	no_button.position = Vector2(224, 140 + extra_space)
	visuals_container.position = Vector2(0, 50 + extra_space)
	visible = true

func open_yn(text):
	open(text, true)

func close():
	get_tree().paused = false
	visible = false
	extra_space = 0
	punnet_square.visible = false

	if len(queue):
		await get_tree().create_timer(.3).timeout
		var queued = queue.pop_front()
		open(queued["lines"], queued["yn_mode"])

func on_yes_pressed():
	close()
	yes_no.emit(true)

func on_no_pressed():
	close()
	yes_no.emit(false)
