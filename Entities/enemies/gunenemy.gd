extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var charging_speed = 40

@export var n_held: Node2D
@export var n_gun: Node2D
@export var n_navagent: NavigationAgent2D

const chase_distance_threshold = 3e5
const shotgun_distance_threshold = 1e5
const desired_squared_distance = 2e4

enum AttackState { IDLE = 0, RIFLE_FOLLOW_THROUGH, SHOTGUN_ANTICIPATION, SHOTGUN_FOLLOW_THROUGH }
const attack_durations = [ null, .7e3, 1.7e3, .2e3 ]
var attack_state = AttackState.IDLE
var attack_frame = 0 

var last_faced_left = false


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	super()


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
		velocity = lerp(velocity, (speed if attack_state != AttackState.SHOTGUN_ANTICIPATION else \
				charging_speed) * (player_offset + n_player.velocity) / sqrt(squared_distance), \
				acceleration * delta)
	else:
		n_navagent.target_position = n_player.global_position
		velocity = (n_navagent.get_next_path_position() - position).normalized() * speed
	move_and_slide()
	
	# Handle aiming and facing direction
	var aim_offset = n_player.global_position - global_position
	n_held.rotation = atan(aim_offset.y / aim_offset.x)
	if aim_offset.x < 0:
		n_held.rotation = 2 * PI - n_held.rotation
		if not last_faced_left:
			scale.x = -1
			last_faced_left = true
	else:
		if last_faced_left:
			scale.x = -1
			last_faced_left = false
	
	# Handle attack and attack animation
	if attack_state == AttackState.IDLE:
		# Add if before this for shotgun range and change following to elif
		if current_time > attack_frame:
			if squared_distance < shotgun_distance_threshold:
				attack_state = AttackState.SHOTGUN_ANTICIPATION
				attack_frame = current_time + attack_durations[AttackState.SHOTGUN_ANTICIPATION]
			elif squared_distance < chase_distance_threshold:
				attack_state = AttackState.RIFLE_FOLLOW_THROUGH
				attack_frame = current_time + attack_durations[AttackState.RIFLE_FOLLOW_THROUGH]
				n_gun.attack()
	elif attack_state == AttackState.RIFLE_FOLLOW_THROUGH:
		if current_time < attack_frame:
			n_gun.scale.x = (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.RIFLE_FOLLOW_THROUGH]) + .8
		else:
			n_gun.scale.x = 1
			attack_state = AttackState.IDLE
	elif attack_state == AttackState.SHOTGUN_ANTICIPATION:
		if current_time < attack_frame:
			n_gun.scale.x = 2 * (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.SHOTGUN_ANTICIPATION]) + .6
		else:
			attack_state = AttackState.SHOTGUN_FOLLOW_THROUGH
			attack_frame = current_time + attack_durations[AttackState.SHOTGUN_FOLLOW_THROUGH]
			n_gun.shotgun_attack()
	else:
		if current_time < attack_frame:
			n_gun.scale.x = 1 - 2 * (attack_frame - current_time) / (5 * \
					attack_durations[AttackState.SHOTGUN_FOLLOW_THROUGH])
		else:
			n_gun.scale.x = 1
			attack_state = AttackState.IDLE
			attack_frame = current_time + attack_durations[AttackState.SHOTGUN_FOLLOW_THROUGH]


