class_name CustomerManager extends Node2D

@onready var spawn_point = $SpawnPoint
@onready var landing_point = $LandingPoint
@onready var timer = $Timer
@onready var customer_scene = preload("res://src/customers/customer.tscn")
@onready var customer: Customer

func _ready():
	timer.timeout.connect(_on_timeout)
	timer.start(1)

func spawn_customer():
	if customer == null:
		await get_tree().create_timer(5).timeout
		var new_customer = customer_scene.instantiate()
		add_child(new_customer)
		new_customer.desired_bouquet = GameProgression.generate_desired_boquet()
		new_customer.set_position(spawn_point.position)
		new_customer.land(landing_point)
		customer = new_customer
	else:
		timer.start(1)

func wait_for_next_customer():
	customer = null
	timer.start(10)

func _on_timeout():
	if GameProgression.customers_unlocked:
		spawn_customer()
		timer.stop()
	else:
		timer.start(1)
