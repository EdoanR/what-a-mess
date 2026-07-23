extends Area2D

@onready var anchor: StaticBody2D = $StaticBody2D
var object_being_hold: PhysicObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()

	if Input.is_action_just_pressed("click"):
		if object_being_hold:
			object_being_hold.drop()
			object_being_hold = null
			return

		var overlappings = get_overlapping_bodies()

		if overlappings.is_empty():
			return

		overlappings.sort_custom(Utils.sort_by_visual_order)
		var body_at_top = overlappings[-1]

		print(overlappings)

		if body_at_top is PhysicObject:
			body_at_top.grab(global_position, anchor)
			object_being_hold = body_at_top
	
	if Input.is_action_just_pressed("lift"):
		lift_object()
	if Input.is_action_just_pressed("lower"):
		lower_object()

func lift_object():
	if not object_being_hold:
		return
	
	object_being_hold.lift()
		
func lower_object():
	if not object_being_hold:
		return

	object_being_hold.lower()
