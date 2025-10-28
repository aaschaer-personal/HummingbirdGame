extends Node2D

@onready var player = $MapPlayer
@onready var levels = $Levels
@onready var level_areas = $LevelAreas
@onready var tutorial_text = $TutorialText
@onready var flowers = $Flowers
@onready var pause_screen = $PauseScreen

var astar
var controllable = true
var level_unlocks
var last_level
var last_complete
var target_level
var intermediate_target_level
var awaiting_double_click_release = false
var config

var level_points = {
	1: Vector2(45, 60),
	2: Vector2(173, 120),
	3: Vector2(253, 182),
	4: Vector2(358, 250),
	5: Vector2(511, 226),
	6: Vector2(536, 36),
	7: Vector2(59, 133),
	8: Vector2(205, 39),
	9: Vector2(234, 238),
	10: Vector2(331, 303),
	11: Vector2(577, 194),
	12: Vector2(613, 47),
}
var point_levels = {}

var level_graph =  {
	1: {
		"right": 2,
		"down": 7,
	},
	2: {
		"left": 1,
		"right": 3,
		"up": 8,
	},
	3: {
		"left": 2,
		"right": 4,
		"down": 9,
	},
	4: {
		"left": 3,
		"right": 5,
		"down": 10,
	},
	5: {
		"left": 4,
		"right": 11,
		"up": 6,
	},
	6: {
		"right": 12,
		"down": 5,
	},
	7: {
		"up": 1,
	},
	8: {
		"down": 2,
	},
	9: {
		"up": 3,
	},
	10: {
		"up": 4,
	},
	11: {
		"left": 5,
	},
	12: {
		"left": 6,
	},
}

func _ready():
	for level in level_points:
		point_levels[level_points[level]] = level
	
	astar = AStar2D.new()
	for level in level_points:
		astar.add_point(level, level_points[level])
	for level in level_graph:
		for direction in level_graph[level]:
			astar.connect_points(level, level_graph[level][direction])

	config = Config.get_config()
	for area in level_areas.get_children():
		area.input_event.connect(
			_on_input_event.bind(int(str(area.name)))
		)

	player.point_reached.connect(_on_point_reached)

	level_unlocks = int(config.get_value("levels", "unlocks", 0))
	levels.play("levels_%d" % (level_unlocks + 1))

	var levels_completed = config.get_value("levels", "completed", 0)
	for level_group in flowers.get_children():
		if levels_completed & 1 << int(str(level_group.name)):
			for flower in level_group.get_children():
				flower.play("bloomed")

	last_level = config.get_value("levels", "last", 1)
	target_level = last_level
	intermediate_target_level = last_level
	player.global_position = level_points[last_level]
	player.target_point = level_points[last_level]

	# bloom flowers on first complete
	last_complete = config.get_value("levels", "last_complete", 0)
	if not levels_completed & 1 << last_complete:
		controllable = false
		config.set_value("levels", "completed", levels_completed | 1 << last_complete)
		for level_group in flowers.get_children():
			if int(str(level_group.name)) == last_complete:
				for flower in level_group.get_children():
					flower.bloom_with_random_delay()
		await get_tree().create_timer(1.5, false).timeout
		controllable = true

	# unlock new levels
	if last_complete > level_unlocks and level_unlocks < 6:
		controllable = false
		level_unlocks = last_complete
		config.set_value("levels", "unlocks", level_unlocks)
		# play level path animation
		levels.play("level_unlocks_%d" % level_unlocks)
		await levels.animation_finished
		controllable = true

	if level_unlocks >= 5:
		var wip_text = $WIPText
		wip_text.visible = true

	if levels.is_playing():
		await levels.animation_finished
	var tween = create_tween()
	tween.tween_property(
		tutorial_text, "modulate", Color.BLACK, .2
	)

func _set_intermediate_target():
	var level_path = astar.get_id_path(last_level, target_level)
	if len(level_path) > 1:
		intermediate_target_level = level_path[1]
	else:
		intermediate_target_level = level_path[0]
	if not player.moving or intermediate_target_level == last_level:
		player.target_point = level_points[intermediate_target_level]

func _input(_event):
	if controllable:
		var direction = null
		if Input.is_action_just_released("left"):
			direction = "left"
		elif Input.is_action_just_released("right"):
			direction = "right"
		elif Input.is_action_just_released("up"):
			direction = "up"
		elif Input.is_action_just_released("down"):
			direction = "down"
		elif Input.is_action_just_released("interact"):
			enter_level(last_level)
		if direction:
			var possible_target = level_graph[intermediate_target_level].get(direction)
			if possible_target and (level_unlocks == 6 or possible_target <= level_unlocks + 1):
				target_level = possible_target
				_set_intermediate_target()

	if Input.is_action_just_released("Esc"):
		pause_screen.visible = true
		get_tree().paused = true
		await get_tree().create_timer(0.01).timeout

func _on_input_event(_viewport, event, _shape, level_num):
	if controllable and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if level_unlocks == 6 or level_num <= level_unlocks + 1:
				target_level = level_num
				_set_intermediate_target()
			awaiting_double_click_release = event.double_click
		else:
			if awaiting_double_click_release:
				enter_level(level_num)

func _on_point_reached():
	last_level = point_levels[player.global_position]
	config.set_value("levels", "last", last_level)
	if last_level != target_level:
		_set_intermediate_target()

func enter_level(level_num):
	if player.global_position == level_points[level_num]:
		Config.save_config()
		var level = load("res://src/levels/level_%d.tscn" % level_num)
		get_tree().change_scene_to_packed(level)
