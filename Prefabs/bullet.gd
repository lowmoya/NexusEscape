extends CharacterBody2D

func _physics_process(delta):
	move_and_collide(velocity)
	if !get_viewport_rect().has_point(global_position):
		queue_free()
