extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Particle = preload("res://Weapons/Projectiles/p_fireparticle.tscn")
@export var n_light: PointLight2D

@export var damage = .4
@export var duration = 1800
@export var knockback = 40


var n_field = null
var n_flames = []
var flame_count = 0

var velocity = Vector2.ZERO
var displacement_magnitude = 200
var perpendicular_direction = null

var start = null
var frame = null

var energy_falloff: float



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	start = Time.get_ticks_msec()
	var selected_duration = duration * randf_range(.8, 1.)
	frame = start + selected_duration
	energy_falloff = 1.e3 / selected_duration

	
	# Get perpendicular direction for displacement
	if velocity.x == 0:
		perpendicular_direction = Vector2(0, 1)
	elif velocity.y == 0:
		perpendicular_direction = Vector2(1, 0)
	else:
		perpendicular_direction = Vector2(1, -velocity.x / velocity.y).normalized()
		
	# Add a perpendicular to the flame direction
	velocity += randf_range(-5,5) * perpendicular_direction
	
	# Randomize the field radius
	n_field = get_node('Field')
	n_field.shape.radius = 40 * randf_range(.8, 1.2)
	n_field.position = n_field.shape.radius * velocity.normalized()

	# Generate the flame particles
	flame_count = randi_range(3, 5)
	n_flames.resize(flame_count)
	for i in range(flame_count):
		n_flames[i] = p_Particle.instantiate()
		n_flames[i].setup(frame, n_field.shape.radius)
		add_child(n_flames[i])
	

func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	if current_time > frame:
		queue_free()
		return
	position += velocity * delta
	n_light.energy -= energy_falloff * delta

	var flame = 0
	while flame < flame_count:
		if n_flames[flame].hit:
			n_flames[flame].queue_free()
			flame_count -= 1
			n_flames[flame] = n_flames[flame_count]
			n_flames.pop_back()
		else:
			flame += 1
	if flame_count == 0:
		queue_free()



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(_body):
	for flame in n_flames:
		flame.n_collider.set_deferred("disabled", false)
		

func _on_body_exited(_body):
	for flame in n_flames:
		flame.n_collider.set_deferred("disabled", true)
