extends Area2D

@onready var timer = $Timer
@onready var collision_shape = $CollisionShape2D
@onready var new_seed = null

func _ready():
	timer.timeout.connect(blow)
	area_entered.connect(_on_area_entered)
	
func blow():
	new_seed = _generate_wind_seed()
	var tween = create_tween()
	var duration = 5
	tween.tween_property(
		collision_shape ,
		"position",
		Vector2(1000,0),
		duration,
	)
	await tween.finished
	collision_shape.position = Vector2.ZERO

func _generate_wind_seed():
	return GenomeGenerator.wild("Lupine")

func _on_area_entered(area):
	if area.has_method("rustle"):
		area.rustle()
		
	if area.is_in_group("plots"):
		if new_seed and area.plant == null:
			area.call_deferred("plant_seed", new_seed)
			new_seed = null
