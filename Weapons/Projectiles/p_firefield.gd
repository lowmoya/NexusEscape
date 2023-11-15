extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = .4
@export var duration = 2000
@export var knockback = 40

class FlameParticle:
	var n_rect
	var color_falloff
	var displacement_radius
	var displacement_direction
	var start
	func _init(parent, frame, max_radius):
		n_rect = ColorRect.new()
		n_rect.size = Vector2(6, 6)
		n_rect.color.r = .7
		n_rect.color.g = randf_range(.4, .7)
		n_rect.color.b = 0
		parent.add_child(n_rect)

		color_falloff = n_rect.color.g / float(frame - Time.get_ticks_msec()) * 1000
		displacement_radius = max_radius * randf_range(.1, 1)
		displacement_direction = Vector2(
				1 if randi_range(0, 1) == 1 else 0,
				1 if randi_range(0, 1) == 1 else 0
			)

		start = Time.get_ticks_msec()


	func update(delta):
		var current_time = Time.get_ticks_msec()
		n_rect.position = displacement_radius * Vector2(
				displacement_direction[0] * cos((current_time - start) / 100.),
				displacement_direction[1] * sin((current_time - start) / 100))
		n_rect.color.g -= color_falloff * delta



var random_generator = RandomNumberGenerator.new()
var n_field = null
var n_flames = []
var flame_count = 0
var color_falloff = 0

var velocity = Vector2.ZERO
var displacement_magnitude = 200
var displacement_direction = Vector2(1, 1)
var perpendicular_direction = null

var start = null
var frame = null



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	start = Time.get_ticks_msec()
	random_generator.seed = start
	frame = start + duration * random_generator.randf_range(.8,1.2)
	
	# Get perpendicular direction for displacement
	if velocity.x == 0:
		perpendicular_direction = Vector2(0, 1)
	elif velocity.y == 0:
		perpendicular_direction = Vector2(1, 0)
	else:
		perpendicular_direction = Vector2(1, -velocity.x / velocity.y).normalized()
		
	# Add a perpendicular to the flame direction
	velocity += random_generator.randf_range(-5,5) * perpendicular_direction
	
	# Randomize the field radius
	n_field = get_node('Field')
	n_field.shape.radius = 40 * randf_range(.8, 1.2)
	n_field.position = n_field.shape.radius * velocity.normalized()

	# Generate the flame particles
	flame_count = random_generator.randf_range(1, 4)
	n_flames.resize(flame_count) 
	for i in range(flame_count):
		n_flames[i] = FlameParticle.new(self, frame, n_field.shape.radius)
	

func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	if current_time > frame:
		queue_free()
		return
	position += velocity * delta
	for flame in n_flames:
		flame.update(delta)


# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if body is Entity:
		# Damage and apply knockback
		# body.velocity += velocity.normalized() * knockback
		body.damage(damage)
	queue_free()
