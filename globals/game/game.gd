extends Node2D

@export var hold_to_drag: bool = false

enum LevelScoreRating {
	PERFECT,
	GOOD,
	BAD
}

func _ready():
	var config = ConfigFile.new()
	config.clear()
	config.save("user://scores.cfg")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
