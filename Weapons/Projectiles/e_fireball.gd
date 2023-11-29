extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = .4
@export var knockback = 400
@export var sprite_frame_duration = 100

@export var n_sprite: Sprite2D
@export var n_light: PointLight2D

var sprite_frame_marker = 0

var velocity = Vector2.ZERO

# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Prepare animation
	n_sprite.frame = randi_range(0, 2)
	sprite_frame_marker = Time.get_ticks_msec() + sprite_frame_duration


func _physics_process(delta):
	# Mechanics
	position += velocity * delta

	# Animation
	var current_time = Time.get_ticks_msec()
	if current_time > sprite_frame_marker:
		n_sprite.frame = n_sprite.frame + 1 if n_sprite.frame != 2 else 0
		sprite_frame_marker = current_time + sprite_frame_duration
		n_light.energy = randf_range(.3, 1.)



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	# Damage and apply knockback
	if body is Entity:
		body.velocity += velocity.normalized() * knockback
		body.damage(damage)
		body.fire_stacks += .5
	queue_free()

