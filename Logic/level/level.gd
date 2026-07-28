class_name Level extends Node2D

@onready var reality: Node2D = $Reality
@onready var expectation: Node2D = $Expectation
@onready var animation_player = $AnimationPlayer

@export var level_id := ""
@export var level_name := ""
@export var count_down_time := 300
@export var goal_score: int = 85
@export var player_cursor: PlayerCursor
@export var count_down: CountDown
@export var hint: Label
@export var max_distance_score = 160.0
@export var max_rotation_angle = 3.0

@export var music: MusicTrack.MUSIC_TRACK_TYPE

@export_category("score result")
@export var organization_bar: ProgressBar
@export var result_score_label: Label
@export var goal_indicator: ColorRect
@export var score_buttons_container: HBoxContainer

@export_category("debugging")
@export var skip_intro := false
@export var override_timer: int = 0

var all_objects: Array[PhysicObject] = []
var expected_obj_groups = {}

var last_obj_index = 0
var first_obj_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	count_down.time_left = count_down_time
	count_down.update_time_label()

	if OS.is_debug_build() and override_timer != 0.0:
		count_down.time_left = override_timer
		count_down.update_time_label()
	Pointer.set_shape(Pointer.PointerShapes.NORMAL)
	AudioManager.stop_music()
	Input.set_use_accumulated_input(false)

	# reality.process_mode = Node.PROCESS_MODE_DISABLED
	expectation.process_mode = Node.PROCESS_MODE_DISABLED

	for child in reality.get_children():
		if not child is PhysicObject:
			continue
		
		var obj = child as PhysicObject
		all_objects.push_back(obj)

		if obj.obj_group:
			var expected_obj = expectation.get_node(str(obj.name)) as PhysicObject
			if expected_obj_groups.has(obj.obj_group):
				var objs_in_group = expected_obj_groups.get(obj.obj_group)
				objs_in_group.push_back(expected_obj)
			else:
				expected_obj_groups.set(obj.obj_group, [expected_obj])

		var idx = obj.get_index()
		last_obj_index = max(last_obj_index, idx)

		if obj.get_collision_layer_value(5):
			first_obj_index = idx + 1

		if first_obj_index == -1:
			first_obj_index = idx
	
	if OS.is_debug_build() and skip_intro:
		animation_player.stop()
		animation_player.play("RESET")
		start()


func start():
	hint.text = "Organize this mess!"
	reality.process_mode = Node.PROCESS_MODE_INHERIT
	count_down.start()
	AudioManager.play_music(music)
	player_cursor.enabled = true

func retry():
	get_tree().reload_current_scene()

func on_timer_almost_finished():
	AudioManager.play_music(MusicTrack.MUSIC_TRACK_TYPE.RUNNIN_OUT_TIME, false)

func on_timer_finished():
	AudioManager.stop_music()
	count_down.timer.stop()

	player_cursor.drop_object()
	player_cursor.enabled = false
	reality.process_mode = Node.PROCESS_MODE_DISABLED
	Pointer.set_shape(Pointer.PointerShapes.NORMAL)
	var score = calculate_room_score()

	var rating = -1

	if score >= 100:
		rating = Game.LevelScoreRating.PERFECT
	elif score >= goal_score:
		rating = Game.LevelScoreRating.GOOD
	else:
		rating = Game.LevelScoreRating.BAD

	var config = ConfigFile.new()
	var _err = config.load("user://scores.cfg")

	config.set_value(level_id, "score_rating", rating)
	config.set_value(level_id, "last_score", score)
	
	var best_score = config.get_value(level_id, "best_score", 0)
	if score > best_score:
		config.set_value(level_id, "best_score", score)

	config.save("user://scores.cfg")

	goal_indicator.position.x = (float(goal_score) / 100) * organization_bar.custom_minimum_size.x
	organization_bar.value = 0.0

	animation_player.play("show_score")
	await animation_player.animation_finished

	organization_bar.value = 0.0
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.RISING_BAR)
	var tween = get_tree().create_tween()
	tween.tween_property(organization_bar, "value", score, 2.0)
	await tween.finished
	await Utils.wait(1.0)

	if rating == Game.LevelScoreRating.PERFECT:
		result_score_label.text = "PERFECT!"
		result_score_label.modulate = Color.YELLOW
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.RETRO_10)
	elif rating == Game.LevelScoreRating.GOOD:
		result_score_label.text = "Well done!"
		result_score_label.modulate = Color.GREEN
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.RETRO_8)
	else:
		result_score_label.text = "Not quite there..."
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.RETRO_6)

	score_buttons_container.visible = true

	print("The end! Result: ", score)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("validate"):
		var score = calculate_room_score()
		print("score: ", score)

func calculate_room_score():
	var total_earned_score: float = 0.0
	var total_importance_pool: float = 0.0

	for obj in all_objects:
		var obj_score: float = 0.0
		var pos_score: float = 0.0
		var rot_score: float = 0.0
		
		# calculating pos score
		# which should be 0.0 to 1.0

		var expected_obj: PhysicObject = null

		if obj.obj_group:
			# if object is in a object group, use the most near expected object of that group
			# to compare and calculate the score
			var objs_in_group = expected_obj_groups.get(obj.obj_group)

			var nearest_distance = 9999999.0
			for item in objs_in_group:
				var group_obj = item as PhysicObject
				var distance = obj.position.distance_to(group_obj.position)
				if distance < nearest_distance:
					expected_obj = group_obj
					nearest_distance = distance
		else:
			expected_obj = expectation.get_node(str(obj.name)) as PhysicObject

		if obj.collision_layer != expected_obj.collision_layer:
			# obj in the wrong layer, immediate position score penalty
			pos_score = 0.0
		else:
			var distance = obj.position.distance_to(expected_obj.position)
			pos_score = clampf(1 - (distance / max_distance_score), 0.0, 1.0)

			if pos_score > 0.95:
				pos_score = 1.0
			
		
		# calculating rotation score
		# which should be 0.0 to 1.0
		var rot_diff = abs(angle_difference(obj.rotation, expected_obj.rotation))

		if obj.rotation_score_judge == PhysicObject.RotationScoreJudge.AMBIGUOUS_EVERY_SIDE:
			rot_score = 1.0 # rotation doesn't matter.
		elif obj.rotation_score_judge == PhysicObject.RotationScoreJudge.AMBIGUOUS_SIDE:
			# We need to care how vertical object is rotated
			rot_score = abs(cos(obj.global_rotation))

			# give some room for perfect rotation score.
			if rot_score >= 0.99:
				rot_score = 1.0
		elif obj.rotation_score_judge == PhysicObject.RotationScoreJudge.NORMAL:
			# We need to care how the object is rotated
			rot_score = clampf(1 - (rot_diff / max_rotation_angle), 0.0, 1.0)

			# give some room for perfect rotation score.
			if rot_score > 0.95:
				rot_score = 1.0


		# calculating object overral score
		var rot_score_weight = 0.65 # how much it matter the rotation compared to position
		obj_score = (pos_score + (rot_score * rot_score_weight)) / (1.0 + rot_score_weight)
		obj_score *= obj.score_importance # add importance weight
		total_earned_score += obj_score
		total_importance_pool += obj.score_importance

		# var label = expected_obj.get_node_or_null("Label") as Label
		# if obj.being_hold:
		# 	if not label:
		# 		label = Label.new()
		# 		expected_obj.add_child(label)
		# 		label.global_position = expected_obj.global_position + Vector2(-100, 0)
		# 		label.name = "Label"

		# 	var label_text = "p:%.2f r:%.2f s:%.2f" % [pos_score, rot_score, obj_score]
		# 	label_text += "\nr_diff:%s" % rot_diff
		# 	label.text = label_text
		# 	label.visible = true
		# else:
		# 	if label:
		# 		label.visible = false
		
	return floor((total_earned_score / total_importance_pool) * 100)
