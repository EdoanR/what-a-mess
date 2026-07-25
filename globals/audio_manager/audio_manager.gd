extends Node2D
## Audio manager node. Inteded to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and [method create_audio()] to handle the playback and culling of simultaneous sound effects.
##
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()] to play those sound effects either at a specific location or globally.
## 
## See https://github.com/Aarimous/AudioManager for more information.
##
## @tutorial: https://www.youtube.com/watch?v=Egf2jgET3nQ

@onready var _current_music_player: AudioStreamPlayer = $AudioStreamPlayer

@export var sfx_bus := "sfx"
@export var music_bus := "music"

@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.
@export var musics: Array[MusicTrack] ## Stores all possible SoundEffects that can be played.

var sound_effect_dict: Dictionary = {} ## Loads all registered SoundEffects on ready as a reference.
var music_tracks_dict: Dictionary = {} ## Music tracks to be played. Key: StringName, Value: AudioStream


func _ready() -> void:
	if "--mute" in OS.get_cmdline_args():
		# mute master bus
		AudioServer.set_bus_mute(0, true)

	var sfx_bus_index := AudioServer.get_bus_index(sfx_bus)
	if sfx_bus_index == -1:
		push_warning("Audio Manager failed to find bus ", sfx_bus)
	
	var music_bus_index := AudioServer.get_bus_index(music_bus)
	if music_bus_index == -1:
		push_warning("Audio Manager failed to find bus ", music_bus)

	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
	
	for music: MusicTrack in musics:
		music_tracks_dict[music.type] = music


## Plays a music track by name. Stops any currently playing music.
## @param track_type The name of the track to play, as defined in the music_tracks_dict dictionary.
## @param loop Whether the music should loop.
@rpc("any_peer", "call_local")
func play_music(track_type: int, loop := true) -> void:
	print("playing music: ", track_type)
	stop_music()

	if not music_tracks_dict.has(track_type):
		push_error("Audio Manager: Music track not found: ", track_type)
		return

	var music_track: MusicTrack = music_tracks_dict[track_type]

	_current_music_player.bus = music_bus
	_current_music_player.stream = music_track.sound_effect
	_current_music_player.volume_db = music_track.volume
	_current_music_player.pitch_scale = music_track.pitch_scale
	_current_music_player.pitch_scale += randf_range(-music_track.pitch_randomness, music_track.pitch_randomness)
	_current_music_player.play()

	if loop:
		_current_music_player.finished.connect(func(): _current_music_player.play())


## Stops the currently playing music track.
@rpc("any_peer", "call_local")
func stop_music() -> void:
	_current_music_player.stop()

## Creates a sound effect at a specific location if the limit has not been reached. Pass [param location] for the global position of the audio effect, and [param type] for the SoundEffect to be queued.
@rpc("any_peer", "call_local")
func create_2d_audio_at_location(type: SoundEffect.SOUND_EFFECT_TYPE, location: Vector2) -> void:
	_create_audio_stream(type, location)

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
@rpc("any_peer", "call_local")
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	_create_audio_stream(type)

func _create_audio_stream(type: SoundEffect.SOUND_EFFECT_TYPE, location = null):
	if location != null and !(location is Vector2):
		push_error("Audio Manager failed to create audio stream. Location must be a Vector2.")
		return

	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		if sound_effect.has_open_limit():
			sound_effect.add_audio_count(1)
			var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
			add_child(new_audio)
			new_audio.bus = sfx_bus
			new_audio.stream = sound_effect.sound_effect
			new_audio.volume_db = sound_effect.volume
			new_audio.pitch_scale = sound_effect.pitch_scale
			new_audio.pitch_scale += randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
			new_audio.finished.connect(sound_effect.on_audio_finished)
			new_audio.finished.connect(new_audio.queue_free)
			new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)
