class_name PhysicObject extends RigidBody2D

enum RotationScoreJudge {
	NORMAL,
	AMBIGUOUS_SIDE,
	AMBIGUOUS_EVERY_SIDE,
}

@onready var level: Level
@onready var sprite: Sprite2D = $Sprite2D
@onready var sprite_original_scale: Vector2 = sprite.scale
@onready var cursor_pinpoint: PinJoint2D = $PinJoint2D
@onready var surface_pinpoint: PinJoint2D = $SurfacePinpoint
@onready var surface_check: Area2D = $MiddleCheck
@onready var objects_check: Area2D = $ObjectsCheck

@export var surface_friction: float = 100
@export var score_importance: float = 1.0
@export var rotation_score_judge: RotationScoreJudge = RotationScoreJudge.NORMAL
@export var obj_group: String = ""

var liftable: bool = false
var surface_attached: PhysicObject = null
var being_hold: bool = false
var hovering: bool = false

func _ready():
	var current_scene = get_tree().current_scene
	if current_scene is Level:
		level = current_scene

	if get_parent().name == "Expectation":
		return
	if (get_collision_layer_value(2) or get_collision_layer_value(4)) and not get_collision_layer_value(3):
		liftable = true
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	attach_to_surface()

	if not surface_attached:
		lower()

func _process(_delta):
	if hovering:
		sprite.scale = sprite_original_scale * 1.02
	else:
		sprite.scale = sprite_original_scale

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
	being_hold = true

	update_hint()

func drop():
	cursor_pinpoint.node_b = ""
	being_hold = false

	if not liftable:
		return
	if not get_collision_layer_value(4):
		return

	var attached = attach_to_surface()
	if attached:
		return
	
	lower()
	update_hint()

func attach_to_surface():
	if not get_collision_layer_value(4):
		return

	var bodies = surface_check.get_overlapping_bodies()
	if name == "Pillow":
		print(bodies)
	for body in bodies:
		if body.get_collision_layer_value(3):
			# surface_pinpoint.node_b = body.get_path()
			surface_attached = body
			return true
	return false

func can_be_lifted():
	if not liftable:
		return false
	if not get_collision_layer_value(2):
		return false
	return true

func can_be_lowered():
	if not liftable:
		return false
	if not get_collision_layer_value(4):
		return false
	return true

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
	
	get_parent().move_child(self, get_tree().current_scene.last_obj_index)
	update_hint()

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
	
	get_parent().move_child(self, get_tree().current_scene.first_obj_index)

	update_hint()

func update_hint():
	if not level:
		return
	
	if can_be_lifted():
		level.hint.text = "Press [ W ] to lift the object to a layer above"
		return
	if can_be_lowered():
		level.hint.text = "Press [ S ] to lower the object to a layer below"
		return
	level.hint.text = ""
