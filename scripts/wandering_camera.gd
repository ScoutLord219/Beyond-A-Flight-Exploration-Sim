extends Camera2D

@onready var delay_timer = $"Delay Timer"
@onready var camera_2d = $"."

@export var map_x_limits : Vector2
@export var map_y_limits : Vector2
@export var movement_curve : Curve
@export var movement_speed : float

var timer_started : bool
var new_desired_location : Vector2
var t : float

signal delay


func _physics_process(delta):
	
	if  new_desired_location.x != 0 && global_position.distance_to(new_desired_location) > 0.5:
		t += delta * movement_speed
		global_position.x = lerpf(global_position.x, new_desired_location.x, movement_curve.sample(t))
		global_position.y = lerpf(global_position.y, new_desired_location.y, movement_curve.sample(t))
	elif !timer_started:
		t = 0
		new_desired_location.x = 0
		timer_started = true
		delay_next_wander()
		await delay
		new_desired_location = pick_wander_location()
	


func pick_wander_location() -> Vector2:
	var desired_x = randf_range(map_x_limits.x, map_x_limits.y)
	var desired_y = randf_range(map_y_limits.x, map_y_limits.y)
	var desired_location = Vector2(desired_x, desired_y)
	return desired_location

func delay_next_wander():
	var random_delay = randf_range(3.0, 5.0)
	delay_timer.start(random_delay)

func _on_delay_timer_timeout():
	print("done!")
	delay.emit()
	timer_started = false
