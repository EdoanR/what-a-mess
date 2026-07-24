class_name Level extends Node2D

@onready var reality: Node2D = $Reality
@onready var expectation: Node2D = $Expectation

@export var max_distance_score = 160.0
@export var max_rotation_angle = 3.0

var last_obj_index = 0
var first_obj_index = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_use_accumulated_input(false)

	for child in reality.get_children():
		if not child is PhysicObject:
			continue
		
		var obj = child as PhysicObject
		var idx = obj.get_index()
		last_obj_index = max(last_obj_index, idx)

		if obj.get_collision_layer_value(5):
			first_obj_index = idx + 1

		if first_obj_index == -1:
			first_obj_index = idx

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("validate"):
		var score = calculate_room_score()
		print("score: ", score)

func calculate_room_score():
	var total_earned_score: float = 0.0
	var total_importance_pool: float = 0.0

	for child in reality.get_children():
		if not child is PhysicObject:
			continue
		
		var obj = child as PhysicObject
		var obj_score: float = 0.0
		var pos_score: float = 0.0
		var rot_score: float = 0.0
		
		# calculating pos score
		# which should be 0.0 to 1.0
		var expected_obj = expectation.get_node(str(obj.name)) as PhysicObject

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

		var label = expected_obj.get_node_or_null("Label") as Label
		if obj.being_hold:
			if not label:
				label = Label.new()
				expected_obj.add_child(label)
				label.global_position = expected_obj.global_position + Vector2(-100, 0)
				label.name = "Label"

			var label_text = "p:%.2f r:%.2f s:%.2f" % [pos_score, rot_score, obj_score]
			label_text += "\nr_diff:%s" % rot_diff
			label.text = label_text
			label.visible = true
		else:
			if label:
				label.visible = false
		
	return (total_earned_score / total_importance_pool) * 100
