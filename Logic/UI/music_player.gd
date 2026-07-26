extends Node2D

@export var music: MusicTrack.MUSIC_TRACK_TYPE
@export var loop := true
@export var restart := false

func play_music():
	if not restart and AudioManager.current_music_type == music:
		return
	AudioManager.play_music(music, loop)

func stop():
	AudioManager.stop_music()
