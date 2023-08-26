extends Area2D

var velocity = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta
	if !get_viewport_rect().has_point(global_position):
		queue_free()


func _on_body_entered(body):
	queue_free()
	if body.is_in_group("Good"):
		body.velocity -= velocity
	pass
