extends CanvasLayer

@onready var pointer = $Pointer
@onready var sprite = $Pointer/Sprite2D

enum PointerShapes {
	NORMAL,
	READY_TO_GRAB,
	GRABBING
}

var current_shape: PointerShapes = PointerShapes.NORMAL

@export var cursor_normal: Texture2D
@export var cursor_ready_to_grab: Texture2D
@export var cursor_grabbing: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pointer.global_position = pointer.get_global_mouse_position()

func set_shape(new_shape: PointerShapes):
	if current_shape == new_shape:
		return
	
	if new_shape == PointerShapes.NORMAL:
		sprite.texture = cursor_normal
	elif new_shape == PointerShapes.READY_TO_GRAB:
		sprite.texture = cursor_ready_to_grab
	elif new_shape == PointerShapes.GRABBING:
		sprite.texture = cursor_grabbing

	current_shape = new_shape
