extends Node2D

@onready var path_follow = $Path2D/PathFollow2D
@onready var levels = $Levels
@onready var level_areas = $LevelAreas
@onready var tutorial_text = $TutorialText
@onready var flowers = $Flowers
@onready var pause_screen = $PauseScreen

var controllable = true
var levels_unlocked
var last_level
var last_complete
var target_level
var move_speed = 200
var awaiting_double_click_release = false
var config

var level_progress_map =  {
	1: 0,
	2: 96.5,
	3: 203.5,
	4: 307.5,
	5: 401.5,
	6: 520,
	7: 715.5,
}

func _ready():
	config = Config.get_config()
	for area in level_areas.get_children():
		area.input_event.connect(
			_on_input_event.bind(int(str(area.name)))
		)
		area.area_entered.connect(
			_on_area_entered.bind(int(str(area.name)))
		)

	levels_unlocked = config.get_value("levels", "unlocked", 1)
	levels.play("level_%d" % levels_unlocked)
	for level in range (1, levels_unlocked):
		for level_group in flowers.get_children():
			if int(str(level_group.name)) == level:
				for flower in level_group.get_children():
					flower.play("bloomed")
	
	last_level = config.get_value("levels", "last", 1)
	path_follow.progress = level_progress_map[last_level]
	target_level = last_level
	
	last_complete = config.get_value("levels", "last_complete", 0)
	if last_complete == levels_unlocked and levels_unlocked < 7:
		controllable = false
		levels_unlocked = last_complete + 1
		config.set_value("levels", "unlocked", levels_unlocked)
		# bloom flowers from previous level, should take 1.5s
		for level_group in flowers.get_children():
			if int(str(level_group.name)) == last_complete:
				for flower in level_group.get_children():
					flower.bloom_with_random_delay()
		await get_tree().create_timer(1.5).timeout
		# play level path animation
		levels.play("level_%d_unlock" % levels_unlocked)
		await levels.animation_finished
		controllable = true

	if levels_unlocked >= 3:
		var wip_text = $WIPText
		wip_text.visible = true

	if levels.is_playing():
		await levels.animation_finished
	var tween = create_tween()
	tween.tween_property(
		tutorial_text, "modulate", Color.BLACK, .2
	)

func _input(_event):
	if controllable:
		if Input.is_action_just_released("left"):
			if target_level <= last_level:
				target_level = max(target_level - 1, 1)
			else:
				target_level = last_level
		elif Input.is_action_just_released("right"):
			if target_level >= last_level:
				target_level = min(target_level + 1, levels_unlocked)
			else:
				target_level = last_level
		elif Input.is_action_just_released("interact"):
			enter_level(last_level)
	if Input.is_action_just_released("Esc"):
		var flag = pause_screen.visible
		controllable = flag
		pause_screen.visible = not flag

func _process(delta):
	var target_progress = level_progress_map[target_level]
	var speed = move_speed * delta
	if path_follow.progress < target_progress:
		if path_follow.progress < target_progress + speed:
			path_follow.progress += speed
		else:
			path_follow.progress = target_progress
	elif path_follow.progress > target_progress:
		if path_follow.progress > target_progress + speed:
			path_follow.progress -= speed
		else:
			path_follow.progress = target_progress

func _on_input_event(_viewport, event, _shape, level_num):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if level_num <= levels_unlocked:
				target_level = level_num
			awaiting_double_click_release = event.double_click
		else:
			if awaiting_double_click_release:
				enter_level(level_num)

func _on_area_entered(_area, level_num):
	last_level = level_num
	config.set_value("levels", "last", last_level)

func enter_level(level_num):
	if path_follow.progress == level_progress_map[last_level]:
		Config.save_config()
		var level = load("res://src/levels/level_%d.tscn" % level_num)
		get_tree().change_scene_to_packed(level)
