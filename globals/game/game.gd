extends Node2D

signal settings_loaded

@export var hold_to_drag: bool = false

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
		
		for i in range(AudioServer.get_bus_count()):
			var bus_name = AudioServer.get_bus_name(i)
			var volume_linear = config.get_value("audio", bus_name, -1.0)
			if volume_linear >= 0.0:
				AudioServer.set_bus_volume_db(i, linear_to_db(volume_linear))
	
	settings_loaded.emit()

func save_settings() -> void:
	if save_timer and not save_timer.is_stopped():
		save_timer.stop()
	var config = ConfigFile.new()
	var _err = config.load(SETTINGS_PATH)
	
	config.set_value("game", "hold_to_drag", hold_to_drag)
	
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
