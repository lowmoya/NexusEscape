extends CharacterBody2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = 1.2
@export var knockback = 400

# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _physics_process(delta):
	position += velocity * delta



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	# Handle cases where the bullet or this collision event will be discarded
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
	
	# Damage and apply knockback
	body.velocity += velocity.normalized() * knockback
	body.damage(damage)
	queue_free()

