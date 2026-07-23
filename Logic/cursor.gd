extends Area2D

var object_being_hold: Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()

	if Input.is_action_just_pressed("click"):
		if object_being_hold:
			object_being_hold.leave_object()
			object_being_hold = null
			return

		var overlappings = get_overlapping_areas()

		if overlappings.is_empty():
			return

		overlappings.sort_custom(_sort_by_visual_order)
		var area_at_top = overlappings[-1]

		if area_at_top.has_method("hold_object"):
			area_at_top.hold_object()
			object_being_hold = area_at_top
		

func _sort_by_visual_order(a: Area2D, b: Area2D):
	if a.z_index != b.z_index:
		return a.z_index < b.z_index
	
	var aidx = a.get_index()
	var bidx = b.get_index()

	return aidx < bidx