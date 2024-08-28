extends Node


@onready var area_2d = $Area2D
@onready var score_label = %ScoreLabel
@onready var timer = $Timer
@onready var player = %Player
@onready var trophy = %Trophy

var time_completed_in = 0.0
var interation = 0

func _ready():
	score_label.hide()
	trophy.hide()
	time_completed_in = 0.0

func _process(delta):
	time_completed_in += delta
func reveal_final_score():
	score_label.show()
	score_label.text = "time completed in: "
	timer.start(0.67)
func _on_timer_timeout():
	if(interation == 0):
		score_label.text = "time completed in: " + str(snappedf(time_completed_in, 0.001))
		determine_trophy_quality()
		timer.start(5)
	else:
		get_tree().reload_current_scene()
	interation += 1

func determine_trophy_quality():
	trophy.show()
	if time_completed_in <= 17.0:
		trophy.play("stupendous")
	elif time_completed_in <= 27.0:
		trophy.play("good")
	elif time_completed_in <= 37.0:
		trophy.play("mediocre")
	else:
		trophy.play("poor")
func _on_area_2d_body_entered(_body):
	player.safe = true
	reveal_final_score()
