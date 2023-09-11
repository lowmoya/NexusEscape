extends Area2D

@export var knockback = 400

var velocity = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta


func _on_body_entered(body):
	if body is TileMap:
		queue_free()
		return
	elif not (body is Entity):
		return
	
	elif is_in_group("Good"):
		if body.is_in_group("Good"):
			return
	elif is_in_group("Bad"):
		if body.is_in_group("Bad"):
			return
	queue_free()
	
	body.velocity += velocity.normalized() * knockback
	body.damage(1)

