class_name PlayerCursor extends Area2D

@onready var anchor: StaticBody2D = $StaticBody2D
var object_being_hold: PhysicObject
var hovering_object: PhysicObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()

	if object_being_hold and hovering_object:
		hovering_object.hovering = false
		hovering_object = null

	var overlappings = get_overlapping_bodies()

	if not overlappings.is_empty():
		overlappings.sort_custom(Utils.sort_by_visual_order)
		var body_at_top = overlappings[-1]
		if body_at_top is PhysicObject:
			if hovering_object and hovering_object != body_at_top:
				hovering_object.hovering = false

			hovering_object = body_at_top

			if not object_being_hold:
				hovering_object.hovering = true

	update_pointer(overlappings)

	if Input.is_action_just_pressed("click") or (Game.hold_to_drag and Input.is_action_just_released("click")):
		if object_being_hold:
			object_being_hold.drop()
			object_being_hold = null
			return

		if hovering_object:
			hovering_object.grab(global_position, anchor)
			object_being_hold = hovering_object
	
	if object_being_hold and Input.is_action_just_pressed("lift_or_lower"):
		if object_being_hold.can_be_lifted():
			lift_object()
		elif object_being_hold.can_be_lowered():
			lower_object()
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

func update_pointer(overlappings: Array[Node2D]):
	if object_being_hold:
		Pointer.set_shape(Pointer.PointerShapes.GRABBING)
	elif not overlappings.is_empty():
		Pointer.set_shape(Pointer.PointerShapes.READY_TO_GRAB)
	else:
		Pointer.set_shape(Pointer.PointerShapes.NORMAL)
