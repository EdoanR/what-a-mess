class_name CountDown extends Label

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

@export var time_left: int = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	update_time_label()

func start():
	timer.start()

func update_time_label():
	text = Utils.format_time(time_left)

func _on_timer_timeout():
	time_left = max(time_left - 1, 0)
	update_time_label()

	if time_left == 120 or time_left == 60 or time_left < 10:
		pulse()

	if time_left == 0:
		time_finished()
		timer.stop()

func pulse():
	animation_player.play("pulse")

func time_finished():
	var level = get_tree().current_scene as Level
	level.on_timer_finished()
