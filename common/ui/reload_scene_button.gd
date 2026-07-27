extends Button

func _ready():
	pressed.connect(reload_scene)

func reload_scene():
	get_tree().reload_current_scene()
