extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = Game.hold_to_drag
	toggled.connect(_toggle_change)


func _toggle_change(toggled_on):
	Game.hold_to_drag = toggled_on
