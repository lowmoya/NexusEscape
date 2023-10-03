extends Area2D



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = .4
@export var duration = 2000
@export var knockback = 40

var random_generator = RandomNumberGenerator.new()

var velocity = Vector2.ZERO
var displacement_magnitude = 4
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
		
	velocity += random_generator.randf_range(-5,5) * perpendicular_direction
	
	# Initialize random aspects of displacement
	displacement_magnitude *= random_generator.randf_range(.1,1)
	if random_generator.randi_range(0,1) == 1:
		displacement_direction.x = -1
	if random_generator.randi_range(0,1) == 1:
		displacement_direction.y = -1
	

func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	if current_time > frame:
		queue_free()
		return
	position += velocity * delta + displacement_magnitude * Vector2( \
			displacement_direction.x * cos((current_time - start) / 100.) + PI / 2., \
			displacement_direction.y * sin((current_time - start) / 100.))



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

