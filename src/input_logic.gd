extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")
@onready var cache_ui = get_tree().get_first_node_in_group("cache_ui")
@onready var click_started_area = null

func _ready():
	randomize()

# esc to exit cache ui or pause
func _input(event):
	if event.is_action_released("Esc"):
		if cache_ui.visible:
			cache_ui.close()
		else:
			pause_screen.visible = true
			await get_tree().create_timer(0.01).timeout
			get_tree().paused = true

# global clicking logic
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point = PhysicsPointQueryParameters2D.new()
		point.position = event.position
		point.collide_with_bodies = false
		point.collide_with_areas = true
		var overlapping_areas = get_world_2d().direct_space_state.intersect_point(point)
		var clickables = []
		var selected = null
		for area in overlapping_areas:
			area = area.collider
			if area == player.held_item:
				continue
			elif area is Interactable and area.is_interactable():
				clickables.append(area)
				break

		for area in clickables:
			# always pick the same area as when the click started
			if area == click_started_area:
				selected = area
				break
			# prioritize portable items to prevent them getting stuck
			elif area is Item:
				selected = area
				break

		if selected == null and clickables:
			selected = clickables[0]

		if event.is_pressed():
			click_started_area = selected
		elif event.is_released():
			if click_started_area != null and click_started_area == selected:
				click_started_area.on_selected(event.position)
			else:
				player.move_to_point(event.position)
			click_started_area = null
