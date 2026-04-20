extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")
@onready var cache_ui = get_tree().get_first_node_in_group("cache_ui")
@onready var click_started_area = null

func _ready():
	randomize()

func _input(event):
	# pause and exit_menu both default to esc	
	if event.is_action_released("pause") and event.is_action_released("exit_menu"):
		if pause_screen.options.ignore_next_exit:
			pause_screen.options.ignore_next_exit = false
		elif pause_screen.options.ignore_next_pause:
			pause_screen.options.ignore_next_pause = false
		elif cache_ui.visible:
			cache_ui.close()
		elif not pause_screen.visible:
			pause_screen.visible = true
			get_tree().paused = true
		elif pause_screen.guide.visible:
			pause_screen.guide.visible = false
		elif pause_screen.options.visible:
			pause_screen.options.close()
		elif pause_screen.visible:
			pause_screen.visible = false
			get_tree().paused = false

	elif event.is_action_released("pause"):
		if pause_screen.options.ignore_next_pause:
			pause_screen.options.ignore_next_pause = false
		# don't overlap menus
		elif cache_ui.visible:
			pass
		elif not pause_screen.visible:
			pause_screen.visible = true
			get_tree().paused = true
		else:
			pause_screen.guide.visible = false
			pause_screen.options.visible = false
			pause_screen.visible = false
			get_tree().paused = false
	
	elif event.is_action_released("exit_menu"):
		if pause_screen.options.ignore_next_exit:
			pause_screen.options.ignore_next_exit = false
		elif pause_screen.guide.visible:
			pause_screen.guide.visible = false
		elif pause_screen.options.visible:
			pause_screen.options.close()
		elif pause_screen.visible:
			pause_screen.visible = false
			get_tree().paused = false
		elif cache_ui.visible:
			cache_ui.close()

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
