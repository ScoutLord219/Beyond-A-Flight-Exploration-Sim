extends AudioStreamPlayer2D


const INITIAL = preload("res://assets/audio/initial.mp3")
const BEYOND = preload("res://assets/audio/beyond.mp3")

var scene_already_loaded : bool = false

func play_track(track):
	stop()
	stream = track
	play()
