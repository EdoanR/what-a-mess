class_name SelectableLevel extends Button

@onready var best_score_label: Label = $BestScore
@onready var best_time_label: Label = $BestTime
@onready var perfect_control: Control = $Perfect
@onready var done_control: Control = $Done

@export var level_id: String = ""
@export_file("*.tscn") var level_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)

	done_control.visible = false
	perfect_control.visible = false
	best_score_label.visible = false
	best_time_label.visible = false

	var config = ConfigFile.new()
	var err = config.load("user://scores.cfg")
	if err != OK:
		return

	if level_id == "":
		print("Warning, selectable level with no level_id")
		return
	
	var rating = config.get_value(level_id, "score_rating", null)
	if rating == null:
		return
	
	if rating == Game.LevelScoreRating.PERFECT:
		perfect_control.visible = true
	elif rating == Game.LevelScoreRating.GOOD:
		done_control.visible = true
	
	var best_score_value = config.get_value(level_id, "best_score", null)
	if best_score_value == null:
		return
	
	best_score_label.text = "Best score: %d%%" % best_score_value
	best_score_label.visible = true

	var best_time_value = config.get_value(level_id, "best_time", null)
	if best_time_value == null:
		return
	
	best_time_label.text = "In %s" % Utils.format_time(best_time_value)
	best_time_label.visible = true

	
func _on_pressed():
	get_tree().change_scene_to_file(level_scene)
