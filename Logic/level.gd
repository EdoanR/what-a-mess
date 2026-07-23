class_name Level extends Node2D

@onready var reality: Node2D = $Reality
@onready var expectation: Node2D = $Expectation

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_use_accumulated_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("validate"):
		validate_room()

func validate_room():
	var score := 0

	var objects_count := 0
	for child in reality.get_children():
		if not child is PickableObject:
			continue
		
		objects_count += 1

		# pos comparison
		var expected_child = expectation.get_node(str(child.name))
		var distance = child.position.distance_to(expected_child.position)

		# rotation comparison
		var rot_diff = abs(angle_difference(child.rotation, expected_child.rotation))

		var pos_score = 0
		var rot_score = 0

		if distance > 50:
			pos_score = 0 # bad
		elif distance > 10:
			pos_score = 25 # good
		else:
			pos_score = 50 # perfect

		if rot_diff <= 0.1:
			rot_score = 50 # perfect
		else:
			rot_score = 0 # bad
		
		var obj_score = pos_score + rot_score
		score += obj_score

		var label = expected_child.get_node_or_null("Label")
		if not label:
			label = Label.new()
			expected_child.add_child(label)
			label.global_position = expected_child.global_position + Vector2(0, 0)
			label.name = "Label"

		var label_text = "%.2f %s" % [distance, rot_diff]
		label_text += " " + str(obj_score)

		if obj_score == 100:
			label_text += " ⭐"
		if obj_score == 50:
			label_text += " ~"
		if obj_score == 0:
			label_text += " :("

		label.text = label_text
		
	score = score / objects_count

	print("score ", score)
