extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var attack_delay = .5

var n_sprite = null
var n_held = null
var n_weapon = null
var n_player = null

# Dashing variables
enum DashStates { BUILDING = 0, MOVING, RECHARGING };
var dash_durations =  [ 1000., 200., 2000. ]
var dash_state = DashStates.RECHARGING
var dash_frame = Time.get_ticks_msec() + 1000
var dash_distance_threshold = 300 ** 2
var dash_strength = 2020
var dash_scale = .2
var normal_scaling = Vector2(scale.x, scale.y)

var current_attack_delay = 0 



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_sprite = get_node("Sprite")
	n_player = get_tree().current_scene.get_node("Player")
	
	# Initialize state
	health = max_health
	current_attack_delay = attack_delay


func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	
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
		if (global_position.x - n_player.global_position.x) ** 2 + (global_position.y - n_player.global_position.y) ** 2 < dash_distance_threshold:
			dash_frame = current_time + dash_durations[DashStates.BUILDING]
			scale = normal_scaling
		elif dash_frame < current_time:
			dash_state = DashStates.MOVING
			dash_frame = current_time + dash_durations[DashStates.MOVING]
		else:
			var winding = 1 - (dash_frame - current_time) / dash_durations[DashStates.BUILDING]
			scale.x = normal_scaling.x + winding * dash_scale
			scale.y = normal_scaling.y - winding * dash_scale
	
	# Adjust velocity and move
	var move = Vector2(n_player.velocity + n_player.global_position - global_position).normalized()
	velocity = lerp(velocity, move * (speed + dash_bonus), acceleration * delta)
	n_sprite.scale.x = -4 if velocity.x < 0 else 4
	move_and_slide()

	

