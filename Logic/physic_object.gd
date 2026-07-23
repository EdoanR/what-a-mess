class_name PhysicObject extends RigidBody2D

@onready var cursor_pinpoint: PinJoint2D = $PinJoint2D
@onready var surface_pinpoint: PinJoint2D = $SurfacePinpoint
@onready var surface_check: Area2D = $MiddleCheck
@onready var objects_check: Area2D = $ObjectsCheck

@export var surface_friction: float = 100

var liftable: bool = false
var surface_attached: PhysicObject = null

func _ready():
	if (get_collision_layer_value(2) or get_collision_layer_value(4)) and not get_collision_layer_value(3):
		liftable = true

func _physics_process(_delta):
	if not surface_attached:
		return

	var new_velocity = surface_attached.linear_velocity - linear_velocity
	new_velocity *= mass
	new_velocity *= surface_friction
	apply_central_force(new_velocity)

	if surface_check.get_overlapping_bodies().is_empty():
		surface_attached = null
		lower()

func grab(clicked_global_pos: Vector2, anchor: CollisionObject2D):
	# surface_pinpoint.node_b = ""
	surface_attached = null
	cursor_pinpoint.global_position = clicked_global_pos
	cursor_pinpoint.node_b = anchor.get_path()

func drop():
	cursor_pinpoint.node_b = ""

	if not liftable:
		return
	if not get_collision_layer_value(4):
		return

	var bodies = surface_check.get_overlapping_bodies()
	print(bodies)
	for body in bodies:
		if body.get_collision_layer_value(3):
			print("body to pin ", body)
			# surface_pinpoint.node_b = body.get_path()
			surface_attached = body
			return
	
	lower()

func lift():
	if not liftable:
		return
	
	var is_on_floor = get_collision_layer_value(2)

	if not is_on_floor:
		return

	var overlapping_bodies = objects_check.get_overlapping_bodies()
	overlapping_bodies.sort_custom(Utils.sort_by_visual_order)

	print("analysing the overllaping bodies:")
	print(overlapping_bodies)

	var found_the_one_being_hold = false
	var found_middle_bodies_between_one_being_hold = false
	for body in overlapping_bodies:
		if not found_the_one_being_hold and body == self:
			found_the_one_being_hold = true
			print("found the one being hold: ", body)
			continue

		if found_the_one_being_hold:
			var is_middle = body.get_collision_layer_value(3)

			if is_middle:
				if body.has_method("shake"):
					body.shake()
				found_middle_bodies_between_one_being_hold = true
	
	if found_middle_bodies_between_one_being_hold:
		return
	
	set_collision_mask_value(2, false)
	set_collision_mask_value(4, true)
	set_collision_layer_value(2, false)
	set_collision_layer_value(4, true)
	z_index += 1

func lower():
	if not liftable:
		return
	
	var is_on_top = get_collision_layer_value(4)

	if not is_on_top:
		return

	var overlapping_bodies = objects_check.get_overlapping_bodies()
	overlapping_bodies.sort_custom(Utils.sort_by_visual_order)
	overlapping_bodies.reverse()

	print("analysing the overllaping bodies:")
	print(overlapping_bodies)

	var found_the_one_being_hold = false
	var found_middle_bodies_between_one_being_hold = false
	for body in overlapping_bodies:
		if not found_the_one_being_hold and body == self:
			found_the_one_being_hold = true
			print("found the one being hold: ", body)
			continue

		if found_the_one_being_hold:
			var is_middle = body.get_collision_layer_value(3)

			if is_middle:
				if body.has_method("shake"):
					body.shake()
				found_middle_bodies_between_one_being_hold = true
	
	if found_middle_bodies_between_one_being_hold:
		return
	
	set_collision_mask_value(4, false)
	set_collision_mask_value(2, true)
	set_collision_layer_value(4, false)
	set_collision_layer_value(2, true)
	z_index -= 1