@tool
class_name PivotOffsetControl extends Node2D
## This centers the pivot offset of parent control node on start or every frame.
## This is useful for scaling or rotating control node without it's pivot being
## in the top left. 

enum PivotOffsetControlPosition {
	TOP_LEFT,
	TOP_RIGHT,
	CENTER,
	BOTTOM_LEFT,
	BOTTOM_RIGHT,
}

@export_tool_button("Change pivot offset now", "2D") var pivot_action = change_pivot_offset

@export var pivot_position: PivotOffsetControlPosition = PivotOffsetControlPosition.CENTER
@export var change_on_ready := false
@export var change_every_process_frame := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if change_on_ready:
		change_pivot_offset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if change_every_process_frame:
		change_pivot_offset()

func change_pivot_offset():
	var parent = get_parent()
	if parent is Control:
		match pivot_position:
			PivotOffsetControlPosition.CENTER:
				parent.pivot_offset = parent.size / 2
			PivotOffsetControlPosition.TOP_LEFT:
				parent.pivot_offset = Vector2(0, 0)
			PivotOffsetControlPosition.TOP_RIGHT:
				parent.pivot_offset = Vector2(parent.size.x, 0)
			PivotOffsetControlPosition.BOTTOM_LEFT:
				parent.pivot_offset = Vector2(0, parent.size.y)
			PivotOffsetControlPosition.BOTTOM_RIGHT:
				parent.pivot_offset = parent.size
