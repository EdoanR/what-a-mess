extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready():
	button_pressed = Game.hold_to_drag
	toggled.connect(_toggle_change)

func _on_settings_loaded():
	button_pressed = Game.hold_to_drag

func _toggle_change(toggled_on):
	Game.hold_to_drag = toggled_on
	if toggled_on:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_A)
	else:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_B)