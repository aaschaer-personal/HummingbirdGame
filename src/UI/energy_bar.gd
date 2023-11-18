extends TextureProgressBar

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	self.max_value = player.max_energy

func _process(_delta):
	value = player.energy
	if value < max_value/5:
		tint_progress = Colors.red
	elif value < max_value/2:
		tint_progress = Colors.yellow
	else:
		tint_progress = Colors.lightest_green
