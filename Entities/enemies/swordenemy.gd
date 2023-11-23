extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var attack_delay = .5

@export var n_navagent: NavigationAgent2D
@export var n_sprite: Sprite2D
@export var n_sword: Node2D

# Dashing variables
enum DashStates { BUILDING = 0, MOVING, RECHARGING, CHASING };
var dash_durations =  [ 1000., 200., 2000. ]
var dash_state = DashStates.RECHARGING
var dash_frame = Time.get_ticks_msec() + 1000
var dash_distance_threshold = 300 ** 2
var chase_distance_threshold = 300000
var dash_strength = 2020
var dash_scale = .2
var normal_scaling = Vector2(scale.x, scale.y)

const sword_sprite_rx = 70_
const sword_sprite_lx = -80

var current_attack_delay = 0 



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	super()
	current_attack_delay = attack_delay


func _physics_process(delta):
	# If should just idle
	if n_player == null:
		return
	
	
	var player_offset =  n_player.global_position - global_position
	var squared_player_distance = player_offset.x ** 2 + player_offset.y ** 2
	
	var current_time = Time.get_ticks_msec()
	
	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)
	
	# Handle the dashing
	var dash_bonus = 0
	if dash_state == DashStates.MOVING:
		if dash_frame < current_time:
			dash_state = DashStates.RECHARGING
			dash_frame = current_time + dash_durations[DashStates.RECHARGING]
			scale = normal_scaling
		else:
			var unwinding = (dash_frame - current_time) / dash_durations[DashStates.MOVING]
			scale.x = normal_scaling.x + unwinding * dash_scale
			scale.y = normal_scaling.y - unwinding * dash_scale
			dash_bonus = dash_strength
			
	elif dash_state == DashStates.RECHARGING:
		if dash_frame < current_time:
			dash_state = DashStates.BUILDING
			dash_frame = current_time + dash_durations[DashStates.BUILDING]
	else:
		if squared_player_distance < dash_distance_threshold:
			dash_frame = current_time + dash_durations[DashStates.BUILDING]
			scale = normal_scaling
		elif dash_frame < current_time:
			dash_state = DashStates.MOVING
			dash_frame = current_time + dash_durations[DashStates.MOVING]
		else:
			var winding = 1 - (dash_frame - current_time) / dash_durations[DashStates.BUILDING]
			scale.x = normal_scaling.x + winding * dash_scale
			scale.y = normal_scaling.y - winding * dash_scale


	if squared_player_distance < chase_distance_threshold:
		velocity = lerp(velocity, (player_offset + n_player.velocity).normalized() * \
				(speed + dash_bonus), acceleration * delta)
	else:
		n_navagent.target_position = n_player.global_position
		velocity = (n_navagent.get_next_path_position() - position).normalized() * (speed + \
				dash_bonus)

	if velocity.x < 0:
		n_sprite.scale.x = -4
		n_sword.scale.x = -1
		n_sword.position.x = sword_sprite_lx
		n_sword.z_index = 0
	else:
		n_sprite.scale.x = 4
		n_sword.scale.x = 1
		n_sword.position.x = sword_sprite_rx
		n_sword.z_index = -1

	move_and_slide()

	

