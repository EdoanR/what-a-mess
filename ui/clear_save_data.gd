extends Button

@export var confirmation_modal: ConfirmationModal

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)


func _on_pressed():
	confirmation_modal.customize(
		"Are you sure?",
		"This will clear all your save data."
	)

	var is_confirmed = await confirmation_modal.prompt()

	if is_confirmed:
		var config = ConfigFile.new()
		var err = config.load(Constants.SAVING_PATHS.scores)
		if err == OK:
			config.clear()
			config.save(Constants.SAVING_PATHS.scores)
