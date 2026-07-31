extends CheckBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("web"):
		hide()
		return
		
	set_pressed_no_signal(Game.fullscreen)
	toggled.connect(_on_toggled)
	Game.settings_loaded.connect(_on_settings_loaded)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and not OS.has_feature("web"):
		_on_settings_loaded()


func _on_settings_loaded() -> void:
	if not OS.has_feature("web"):
		set_pressed_no_signal(Game.fullscreen)


func _on_toggled(toggled_on: bool) -> void:
	Game.fullscreen = toggled_on
	if toggled_on:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_A)
	else:
		AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.TICK_B)
