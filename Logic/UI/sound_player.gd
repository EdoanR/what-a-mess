extends Node2D

@export var sounds: Array[SoundEffect.SOUND_EFFECT_TYPE] = []

func play_sound():
	AudioManager.create_audio(sounds)
