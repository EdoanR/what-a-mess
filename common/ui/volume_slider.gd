extends HSlider

@export var bus_name: String = ""
@onready var bus_index: int = AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	if not bus_name:
		print("Volume slider with not bus_name ", self)
	_update_slider_value()
	value_changed.connect(_on_value_changed)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		_update_slider_value()

func _update_slider_value() -> void:
	if bus_index >= 0:
		set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(bus_index)))

func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(new_value))
	print("Volume for bus ", bus_name, " is now ", AudioServer.get_bus_volume_db(bus_index))