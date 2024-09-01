class_name WateringCan extends Item

@onready var water_particles = $Item/WaterParticles
@onready var water_zone = $WaterZone
@onready var water_meter = $WaterMeter
@onready var audio_player = $AudioStreamPlayer2D
var water_amount = 20

func _physics_process(delta):
	if player.held_item == self:
		water_meter.visible = true
		if water_amount > 0:
			toggle_water(true)
			water_amount -= delta
			for overlap in water_zone.get_overlapping_areas():
				if overlap is Plot:
					overlap.water(delta)
		else:
			toggle_water(false)
		water_meter.value = water_amount * 5
	else:
		toggle_water(false)
		water_meter.visible = false

func toggle_water(val):
	water_particles.emitting = val
	await get_tree().create_timer(0.5).timeout
	if audio_player.playing != val:
		audio_player.playing = val

func drop():
	super()
	item_sprite.rotation_degrees = 0

func set_flip_h(val):
	item_sprite.set_flip_h(val)
	if not val:
		item_sprite.rotation_degrees = 25
		water_particles.position = Vector2(10,0)
		water_zone.position = Vector2(9,20)
	else:
		item_sprite.rotation_degrees = -25
		water_particles.position = Vector2(-10,0)
		water_zone.position = Vector2(-9,20)

func refill():
	water_amount = 20
