class_name Main extends Node2D

@onready var player = $Player
@onready var cache = $Cache
@onready var pause_screen = $UI/PauseScreen
@onready var click_started_area = null

func _ready():
	randomize()

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
