extends Node2D

@export var scale_multiplier := 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		var visual = child.get_node_or_null("Visual")
		if not visual:
			continue
		
		Utils.pop(visual, scale_multiplier)