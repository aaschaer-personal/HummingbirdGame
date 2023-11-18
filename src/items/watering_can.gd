class_name WateringCan extends Item

@onready var water_particles = $Sprite2D/WaterParticles
@onready var water_zone = $WaterZone
@onready var water_meter = $WaterMeter
var water_amount = 20

func _physics_process(delta):
	if player.held_item == self:
		water_meter.visible = true
		if water_amount > 0:
			water_particles.emitting = true
			water_amount -= delta
			for overlap in water_zone.get_overlapping_areas():
				if overlap is Plot:
					overlap.water(delta)
		else:
			water_particles.emitting = false
		water_meter.value = water_amount * 5
	else:
		water_particles.emitting = false
		water_meter.visible = false

func set_flip_h(val):
	sprite.flip_h = val
	if not val:
		sprite.rotation_degrees = 25
		water_particles.position = Vector2(10,0)
		water_zone.position = Vector2(9,20)
	else:
		sprite.rotation_degrees = -25
		water_particles.position = Vector2(-10,0)
		water_zone.position = Vector2(-9,20)

func refill():
	water_amount = 20
