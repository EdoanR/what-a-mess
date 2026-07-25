extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.visible = false
	
	for child in get_children():
		if child is PhysicObject:
			child.scale *= 1.2
			child.visible = true
			var tween = get_tree().create_tween()
			tween.tween_property(child, "scale", Vector2(1.0, 1.0), 0.1)
			await tween.finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
