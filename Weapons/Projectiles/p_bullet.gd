extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = 1.2
@export var knockback = 400

var velocity = Vector2.ZERO



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _physics_process(delta):
	position += velocity * delta



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if body is Entity:
		# Damage and apply knockback
		body.velocity += velocity.normalized() * knockback
		body.damage(damage)
	elif not body is TileMap:
		body.try(2)
	queue_free()
