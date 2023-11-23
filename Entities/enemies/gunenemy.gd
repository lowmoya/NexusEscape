extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var attack_delay = .5

@export var n_held: Node2D
@export var n_gun: Node2D
@export var n_navagent: NavigationAgent2D

var chase_distance_threshold = 300000

var current_attack_delay = 0 
var last_faced_left = false


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
	
	var current_time = Time.get_ticks_msec()
	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)

	# Adjust velocity and move
	var player_offset =  n_player.global_position - global_position
	var squared_distance: float = player_offset.x ** 2 + player_offset.y ** 2
	if squared_distance < chase_distance_threshold:
		velocity = lerp(velocity, (player_offset + n_player.velocity) * (speed / sqrt(squared_distance)),
				acceleration * delta)
	else:
		n_navagent.target_position = n_player.global_position
		velocity = (n_navagent.get_next_path_position() - position).normalized() * speed
	move_and_slide()
	
	# Adjust held angle for simple predictive aiming
	var aim_offset = n_player.global_position - global_position
	n_held.rotation = atan(aim_offset.y / aim_offset.x)
	if last_faced_left:
		if aim_offset.x >= 0:
			scale.x = -1
			last_faced_left = false
	else:
		if aim_offset.x < 0:
			scale.x = -1
			last_faced_left = true
	
	# Decrement delay, when it hits zero attack and reset it
	current_attack_delay -= delta
	if current_attack_delay <= 0 and squared_distance < chase_distance_threshold:
		n_gun.attack()
		current_attack_delay = attack_delay
	elif current_attack_delay > 0:
		pass
