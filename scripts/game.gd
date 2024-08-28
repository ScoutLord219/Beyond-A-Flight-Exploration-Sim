extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if !Music.scene_already_loaded:
		Music.play_track(Music.BEYOND)
		Music.scene_already_loaded = true
