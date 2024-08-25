extends Button
@onready var animated_sprite_2d = $AnimatedSprite2D

func reload_scene():
	get_tree().reload_current_scene()

func _on_pressed():
	animated_sprite_2d.play("spin")

func _on_animated_sprite_2d_animation_finished():
		reload_scene()
