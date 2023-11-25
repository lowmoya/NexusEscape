extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var charging_speed = 40

@export var n_held: Node2D
@export var n_navagent: NavigationAgent2D
@export var n_gun: Node2D
@export var n_collection_field: ColorRect
@export var n_collection_light: PointLight2D
var n_collection_field_shader: ShaderMaterial
var collection_field_particles = []
var collection_field_particle_accelerations = []
var collection_field_start_time: float
var collection_field_particle_count: int


const chase_distance_threshold = 3e5
const shotgun_distance_threshold = 9e4
const desired_squared_distance = 5e4

enum AttackState {
	IDLE = 0, RIFLE_ANTICIPATION, RIFLE_FOLLOW_THROUGH, SHOTGUN_ANTICIPATION,
	SHOTGUN_FOLLOW_THROUGH
}
const attack_durations = [ .4e3, .2e3, .2e3, 1.7e3, .2e3 ]
var attack_state = AttackState.IDLE
var attack_frame = 0 

const rotation_speed = .5 * PI
const charging_rotation_speed = .3 * PI
var angle = 0
var last_faced_left = false


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	super()
	n_collection_field_shader = ShaderMaterial.new()
	n_collection_field_shader.shader = (n_collection_field.material as ShaderMaterial).shader.duplicate()
	n_collection_field.material = n_collection_field_shader
	collection_field_particles.resize(10)
	collection_field_particle_accelerations.resize(10)


func _physics_process(delta):
	# Handle idle conditions
	if n_player == null:
		return
	
	# Handle hit flash
	var current_time = Time.get_ticks_msec()
	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)

	# Handle movement
	var player_offset =  n_player.global_position - global_position
	var squared_distance: float = player_offset.x ** 2 + player_offset.y ** 2
	if squared_distance < chase_distance_threshold:
		var move = player_offset / sqrt(squared_distance)
		if squared_distance < desired_squared_distance:
			move *= -1
		velocity = lerp(velocity, (speed if attack_state != AttackState.SHOTGUN_ANTICIPATION else \
				charging_speed) * move, acceleration * delta)
	else:
		n_navagent.target_position = n_player.global_position
		velocity = (n_navagent.get_next_path_position() - position).normalized() * speed
	move_and_slide()
	
	# Handle aiming and facing direction
	var aim_offset = n_player.global_position - global_position
	var target_angle = atan2(aim_offset.y, aim_offset.x)
	var angle_distance = angle - target_angle
	if angle_distance > PI:
		angle -= 2 * PI
	elif angle_distance < -PI:
		angle += 2 * PI
	angle = move_toward(angle, target_angle, (rotation_speed if attack_state \
			!= AttackState.SHOTGUN_ANTICIPATION else charging_rotation_speed) * delta)
	if angle > 2 * PI:
		angle -= 2 * PI
	elif angle < 0:
		angle += 2 * PI
	if angle > PI / 2 and angle < 3 * PI / 2:
		n_held.rotation = PI - angle
		if not last_faced_left:
			scale.x = -1
			last_faced_left = true
	else:
		n_held.rotation = angle
		if last_faced_left:
			scale.x = -1
			last_faced_left = false
	
	# Handle attack and attack animation
	if attack_state == AttackState.IDLE:
		# Add if before this for shotgun range and change following to elif
		if current_time > attack_frame and not n_gun.blocked:
			if squared_distance < shotgun_distance_threshold:
				attack_state = AttackState.SHOTGUN_ANTICIPATION
				attack_frame = current_time + attack_durations[AttackState.SHOTGUN_ANTICIPATION]
				collection_field_particle_count = randi_range(3, 7)
				n_collection_field_shader.set_shader_parameter("count", collection_field_particle_count)
				for i in range(collection_field_particle_count):
					collection_field_particles[i] = Vector2(randf_range(.2, 1.), \
							randf_range(.2, 1.))
					collection_field_particle_accelerations[i] = \
							(2. / (attack_durations[AttackState.SHOTGUN_ANTICIPATION] ** 2)) * \
							(Vector2(0., .5) - collection_field_particles[i])
				collection_field_start_time = current_time
			elif squared_distance < chase_distance_threshold:
				attack_state = AttackState.RIFLE_ANTICIPATION
				attack_frame = current_time + attack_durations[AttackState.RIFLE_ANTICIPATION]
	elif attack_state == AttackState.RIFLE_ANTICIPATION:
		if current_time < attack_frame:
			n_gun.scale.x = (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.RIFLE_ANTICIPATION]) + .8
		else:
			attack_state = AttackState.RIFLE_FOLLOW_THROUGH
			attack_frame = current_time + attack_durations[AttackState.RIFLE_ANTICIPATION]
			n_gun.attack()
	elif attack_state == AttackState.RIFLE_FOLLOW_THROUGH:
		if current_time < attack_frame:
			n_gun.scale.x = 1 - (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.RIFLE_FOLLOW_THROUGH])
		else:
			n_gun.scale.x = 1
			attack_state = AttackState.IDLE
			attack_frame = current_time + attack_durations[AttackState.IDLE]
	elif attack_state == AttackState.SHOTGUN_ANTICIPATION:
		if current_time < attack_frame:
			n_gun.scale.x = 2. / 5. * (attack_frame - current_time) / \
					attack_durations[AttackState.SHOTGUN_ANTICIPATION] + .6
			n_collection_light.energy += (current_time - collection_field_start_time) / 300. * delta
			print(n_collection_light.energy, ' ', current_time, ' ', collection_field_start_time)
			for i in range(collection_field_particle_count):
				collection_field_particles[i] += collection_field_particle_accelerations[i] * \
						(current_time - collection_field_start_time) * delta * 1e3
				print(collection_field_particles[i])
			n_collection_field_shader.set_shader_parameter("points", collection_field_particles)
		else:
			n_collection_light.energy = 0.
			attack_state = AttackState.SHOTGUN_FOLLOW_THROUGH
			attack_frame = current_time + attack_durations[AttackState.SHOTGUN_FOLLOW_THROUGH]
			n_gun.shotgun_attack(collection_field_particle_count)
			n_collection_field_shader.set_shader_parameter("count", 0)
	else:
		if current_time < attack_frame:
			n_gun.scale.x = 1 - 2 * (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.SHOTGUN_FOLLOW_THROUGH])
		else:
			n_gun.scale.x = 1
			attack_state = AttackState.IDLE
			attack_frame = current_time + attack_durations[AttackState.IDLE]


