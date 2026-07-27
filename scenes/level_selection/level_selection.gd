extends Node2D

@export var levels: Array[Control]

func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://scores.cfg")
	if err != OK:
		return

	for level in levels:
		var level_name = level.get_meta("level_name")
		if level_name == null:
			print("Warning, no level_name metadata for the level ", level)
			continue
		
		var rating = config.get_value(level_name, "score_rating")
		if rating == null:
			continue
		
		if rating == Game.LevelScoreRating.PERFECT:
			level.get_node("Perfect").visible = true
		elif rating == Game.LevelScoreRating.GOOD:
			level.get_node("Done").visible = true
		
		var best_score = config.get_value(level_name, "best_score")
		if best_score == null:
			continue
		
		level.get_node("BestScore").text = "Best score: %d%%" % best_score
		level.get_node("BestScore").visible = true
