extends CharacterBody2D

const ACCELERATION = 0.3
const TAKEOFF_SPEED = 30.0
const FLIGHT_VELOCITY = -3.5
const TERMINAL_VELOCITY = 250
const PITCH_SPEED = 5

@onready var death_timer = $DeathTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var player = $"."
@onready var switch_audio_stream = $SwitchAudioStream

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") / 3
var throttle_input = Vector2.ZERO
var thrust_input = Vector2.ZERO
var airborn = false
var airborn_flight_speed = FLIGHT_VELOCITY * 1.25
var mode_of_flight = FLIGHT_VELOCITY
var drive_mode = ACCELERATION
var airborn_speed = ACCELERATION * 1.25
var movement_enabled = true
var safe = false

var rotation_direction = Vector2.ZERO

func _ready():
	rotateToTarget(Vector2.RIGHT, 100)

func get_input():
	rotation_direction = Input.get_axis("pitch_down", "pitch_up")
	throttle_input = Input.get_axis("accel_left", "accel_right")
	thrust_input = Input.get_axis("throttle_down", "throttle_up")
func _physics_process(delta):	
	if(movement_enabled):
		#Sprite & Animation
		if(get_real_velocity().x < 0):
			animated_sprite_2d.flip_h = true
		elif (get_real_velocity().x > 0):
			animated_sprite_2d.flip_h = false
		if(velocity == Vector2.ZERO):
			switch_audio_stream.play("RESET")
			animated_sprite_2d.play("idle")
		else:
			animated_sprite_2d.play("flying")
		#Applys the constant force of gravity ( 4.083 )
		velocity.y += clampf((gravity * delta) - (abs(velocity.length() / 10)), 0, TERMINAL_VELOCITY)
		#checks if airborn
		airborn = !is_on_floor()
		#modify's speed based on whether or not airborn
		if(airborn):
			switch_audio_stream.play("switch_to_flight")
			
			mode_of_flight = move_toward(mode_of_flight, airborn_flight_speed, delta * 0.5)
			drive_mode = move_toward(drive_mode, airborn_speed, delta * 0.1)
		else:
			switch_audio_stream.play("switch_to_taxi")
			
			mode_of_flight = move_toward(mode_of_flight, FLIGHT_VELOCITY, delta)
			drive_mode = move_toward(drive_mode, ACCELERATION, delta)
			
		#movement
		rotateToTarget(velocity, delta)
		
		get_input()
		if(abs(velocity.x) >= TAKEOFF_SPEED || airborn):
			#rotation += -rotation_direction * PITCH_SPEED * delta
			velocity.y = clampf((rotation_direction * FLIGHT_VELOCITY) + velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
		else:
			velocity.y = move_toward(velocity.y, TERMINAL_VELOCITY, delta)

		if throttle_input:
			velocity.x = clampf((throttle_input * ACCELERATION) + velocity.x, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
		else:
			velocity.x = move_toward(velocity.x, 0, delta)

		#if thrust_input && (abs(velocity.x) >= TAKEOFF_SPEED || airborn):
		#	velocity.y = clampf((thrust_input * FLIGHT_VELOCITY) + velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
		#else:
		#	velocity.y = move_toward(velocity.y, TERMINAL_VELOCITY, delta)

		#crash detection
		var previous_velocity = velocity
		move_and_slide()
		var change_in_velocity = (previous_velocity - velocity).length()
		if(change_in_velocity >= 44 && !safe):
			movement_enabled = false
			switch_audio_stream.play("crash")
			#play crash anim
			animated_sprite_2d.play("crash")
			Engine.time_scale = 0.5
			death_timer.start(0.45)

func rotateToTarget(direction, delta):
	direction.x = abs(direction.x)
	if(animated_sprite_2d.flip_h):
		direction.y = -direction.y
	var angleTo = animated_sprite_2d.transform.x.angle_to(direction)
	animated_sprite_2d.rotate(sign(angleTo) * min(delta * PITCH_SPEED, abs(angleTo)))
func _on_death_timer_timeout():
	Engine.time_scale = 1
	get_tree().reload_current_scene()
