extends Node2D

func _ready():
	if OS.has_feature("web"):
		$CanvasLayer/QuitGame.visible = false

func quit_game():
	get_tree().quit()
