class_name AutoSaveTrigger extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var parent = get_parent()
	if not parent:
		return
		
	if parent is Range:
		parent.value_changed.connect(_on_value_changed)
	elif parent is OptionButton:
		parent.item_selected.connect(_on_item_selected)
	elif parent is BaseButton:
		parent.toggled.connect(_on_toggled)


func _on_value_changed(_new_value: float) -> void:
	Game.request_save_settings()


func _on_item_selected(_index: int) -> void:
	Game.request_save_settings()


func _on_toggled(_toggled_on: bool) -> void:
	Game.request_save_settings()
