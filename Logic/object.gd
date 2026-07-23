class_name PickableObject extends Area2D

@onready var level: Level = get_tree().current_scene

var holded = false
var hold_offset: Vector2 = Vector2.ZERO

func _process(_delta):
	if not holded:
		return
	
	global_position = get_global_mouse_position() - hold_offset

func _input(event):
	if not holded:
		return
	
	if event.is_action_pressed("rotate_left"):
		# Rotate left (counter clock wise)
		rotate(deg_to_rad(-45))
		print("rotate left ", rotation_degrees)
	
	if event.is_action_pressed("rotate_right"):
		# Rotate right (clock wise)
		rotate(deg_to_rad(45))
		print("rotate right ", rotation_degrees)


func hold_object():
	var mouse_pos = get_global_mouse_position()
	hold_offset = mouse_pos - global_position

	holded = true

	z_index += 1

	get_viewport().set_input_as_handled()

func leave_object():
	holded = false

	get_viewport().set_input_as_handled()
