extends Node2D

signal settings_loaded

@export var hold_to_drag: bool = true
@export var fullscreen: bool = true:
	set(value):
		fullscreen = value
		if not OS.has_feature("web") and DisplayServer.get_name() != "headless":
			if fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				_apply_comfortable_windowed_size()

@onready var save_timer: Timer = $SaveTimer
const SAVE_DEBOUNCE_TIME: float = 0.5
const SETTINGS_PATH: String = "user://settings.cfg"

enum LevelScoreRating {
	PERFECT,
	GOOD,
	BAD
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if save_timer:
		save_timer.timeout.connect(save_settings)
	else:
		print("Game autoload: SaveTimer child node not found.")
	load_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_PATH)
	if err == OK:
		hold_to_drag = config.get_value("game", "hold_to_drag", hold_to_drag)
		if not OS.has_feature("web"):
			var default_fullscreen: bool = not OS.has_feature("editor")
			fullscreen = config.get_value("display", "fullscreen", default_fullscreen)
		
		for i in range(AudioServer.get_bus_count()):
			var bus_name = AudioServer.get_bus_name(i)
			var volume_linear = config.get_value("audio", bus_name, -1.0)
			if volume_linear >= 0.0:
				AudioServer.set_bus_volume_db(i, linear_to_db(volume_linear))
	else:
		if not OS.has_feature("web"):
			# On very first run without a save file: default to Fullscreen in exports, Windowed in Editor
			fullscreen = not OS.has_feature("editor")
	
	settings_loaded.emit()

func _apply_comfortable_windowed_size() -> void:
	# Keep user's override size when running inside the Godot Editor, only size dynamically in builds
	if OS.has_feature("web") or DisplayServer.get_name() == "headless" or OS.has_feature("editor"):
		return
		
	var screen_idx: int = DisplayServer.window_get_current_screen()
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_idx)
	
	# Standard 16:9 resolutions from largest to smallest
	var candidate_sizes: Array[Vector2i] = [
		Vector2i(2560, 1440),
		Vector2i(1920, 1080),
		Vector2i(1600, 900),
		Vector2i(1280, 720),
		Vector2i(960, 540),
		Vector2i(640, 360)
	]
	
	# Select the largest standard size that fits comfortably within ~80% of usable screen area
	var max_w: int = int(usable_rect.size.x * 0.85)
	var max_h: int = int(usable_rect.size.y * 0.82)
	
	var target_size: Vector2i = Vector2i(960, 540) # Safe fallback size
	for size in candidate_sizes:
		if size.x <= max_w and size.y <= max_h:
			target_size = size
			break
			
	DisplayServer.window_set_size(target_size)
	
	# Perfectly center the window within the usable desktop space (avoiding taskbar & title bar clipping)
	var centered_pos: Vector2i = usable_rect.position + (usable_rect.size - target_size) / 2
	DisplayServer.window_set_position(centered_pos)

func save_settings() -> void:
	if save_timer and not save_timer.is_stopped():
		save_timer.stop()
	var config = ConfigFile.new()
	var _err = config.load(SETTINGS_PATH)
	
	config.set_value("game", "hold_to_drag", hold_to_drag)
	if not OS.has_feature("web"):
		config.set_value("display", "fullscreen", fullscreen)
	
	for i in range(AudioServer.get_bus_count()):
		var bus_name = AudioServer.get_bus_name(i)
		var volume_db = AudioServer.get_bus_volume_db(i)
		config.set_value("audio", bus_name, db_to_linear(volume_db))
		
	config.save(SETTINGS_PATH)

func request_save_settings() -> void:
	if save_timer:
		save_timer.start(SAVE_DEBOUNCE_TIME)

func flush_save_settings() -> void:
	if save_timer and not save_timer.is_stopped():
		save_timer.stop()
		save_settings()
