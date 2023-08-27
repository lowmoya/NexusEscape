extends Area2D

var velocity = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta
	if !get_viewport_rect().has_point(global_position):
		queue_free()


func _on_body_entered(body):
	if not (body is Entity):
		return
	elif is_in_group("Good"):
		if body.is_in_group("Good"):
			return
	elif is_in_group("Bad"):
		if body.is_in_group("Bad"):
			return
	queue_free()
	
	body.velocity += velocity
	body.damage(1)
