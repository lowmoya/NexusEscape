extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var n_rect: ColorRect
@export var n_light: PointLight2D

@export var max_duration = 1.4
@export var damage = 1.2
@export var knockback = 400

var velocity = Vector2.ZERO

var duration
var fade_rate


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	duration = max_duration * randf_range(.8, 1.)
	fade_rate = 1. / duration
	

func _physics_process(delta):
	position += velocity * delta
	duration -= delta
	if duration <= 0:
		queue_free()
		return
	n_rect.color = n_rect.color.darkened(fade_rate * delta)
	n_light.energy -= fade_rate * delta



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if body is Entity:
		# Damage and apply knockback
		body.velocity += velocity.normalized() * knockback
		body.damage(damage)
	queue_free()

