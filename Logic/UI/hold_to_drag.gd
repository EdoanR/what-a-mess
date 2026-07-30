extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready():
	set_pressed_no_signal(Game.hold_to_drag)
	toggled.connect(_toggle_change)
	Game.settings_loaded.connect(_on_settings_loaded)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		_on_settings_loaded()

func _on_settings_loaded():
	set_pressed_no_signal(Game.hold_to_drag)

func _toggle_change(toggled_on):
	Game.hold_to_drag = toggled_on
	if toggled_on:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_A)
	else:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_B)