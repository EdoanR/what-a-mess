extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.visible = false
	
	var pitch_increase = 0.1
	var i = -1
	for child in get_children():
		if child is PhysicObject:
			i += 1
			child.scale *= 1.2
			child.visible = true
			var sounds = [
				SoundEffect.SOUND_EFFECT_TYPE.POP_A,
			]
			AudioManager.create_audio(sounds, 1.0 + (pitch_increase * (i + 1)))
			var tween = get_tree().create_tween()
			tween.tween_property(child, "scale", Vector2(1.0, 1.0), 0.1)
			await tween.finished


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
