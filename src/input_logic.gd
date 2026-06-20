extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var drop_point = get_tree().get_first_node_in_group("drop_point")
@onready var pause_screen = get_tree().get_first_node_in_group("pause_screen")
@onready var pause_button = get_tree().get_first_node_in_group("pause_button")
@onready var cache_ui = get_tree().get_first_node_in_group("cache_ui")
@onready var intro_screen = get_tree().get_first_node_in_group("intro_screen")
@onready var click_started_area = null

func _ready():
	randomize()

func _input(event):
	if event.is_action_released("interact") and player.controllable:
		player.interact_with_nearest_target()

	elif event.is_action_released("drop") and player.controllable:
		player.drop_held_item()

	# pause and exit_menu both default to esc
	elif event.is_action_released("pause") and event.is_action_released("exit_menu"):
		if cache_ui.visible:
			cache_ui.close()
		elif intro_screen.visible:
			intro_screen.close()
		elif pause_screen.punnet_square.visible:
			pause_screen.punnet_square.visible = false
		elif pause_screen.guide.visible:
			pause_screen.guide.visible = false
		elif pause_screen.options.visible:
			pause_screen.options.close()
		elif pause_screen.visible:
			pause_screen.visible = false
			get_tree().paused = false
		elif not pause_screen.visible:
			pause_screen.visible = true
			get_tree().paused = true

	elif event.is_action_released("exit_menu"):
		if pause_screen.punnet_square.visible:
			pause_screen.punnet_square.visible = false
		elif pause_screen.guide.visible:
			pause_screen.guide.visible = false
		elif pause_screen.options.visible:
			pause_screen.options.close()
		elif pause_screen.visible:
			pause_screen.visible = false
			get_tree().paused = false
		elif intro_screen.visible:
			intro_screen.close()
		elif cache_ui.visible:
			cache_ui.close()

	elif event.is_action_released("pause"):
		# don't overlap menus
		if cache_ui.visible or intro_screen.visible:
			pass
		elif not pause_screen.visible:
			pause_screen.visible = true
			get_tree().paused = true
		else:
			pause_screen.guide.visible = false
			pause_screen.visible = false
			if pause_screen.options.visible:
				pause_screen.options.close()
			get_tree().paused = false
			
	elif event.is_action_released("punnet_square"):
		# don't overlap menus
		if cache_ui.visible or intro_screen.visible:
			pass
		else:
			var punnet_open = pause_screen.punnet_square.visible
			get_tree().paused = not punnet_open
			pause_screen.visible = not punnet_open
			if not punnet_open:
				pause_screen.open_punnet_square()
			else:
				pause_screen.punnet_square.visible = false

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
			# iteraction takes priority over dropping
			if not selected and event.double_click:
				drop_point.global_position = event.position
				# wait for area to move
				await get_tree().create_timer(0.1, false).timeout
				player.set_interaction_target(
					"_drop_item_at_point",
					null,
					player.pickup_area,
					drop_point,
					event.position,
				)
		elif event.is_released():
			if click_started_area != null and click_started_area == selected:
				click_started_area.on_selected(event.position)
			else:
				player.move_to_point(event.position)
			click_started_area = null
