extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var desired_distance = 500

@export var n_navagent: NavigationAgent2D

var n_scene = null
var n_toprays = []
var n_bottomrays = []
var n_sprite = null
var p_Fireball = preload("res://Weapons/Projectiles/e_fireball.tscn")
var fireball_speed = 300

enum STATE {
	COOLING, # State frame holding how long to return to approaching state
	APPROACHING, # State frame holding how long before can fire again
	CHARGING, # State frame holding how long before fires
}

var state = STATE.APPROACHING
var state_frame = 0

var animation_frame
var animation_frame_duration = 100

var charging_move_speed = 40
var cooling_duration = 140.
var approaching_duration = 2000.
var attack_duration = 2200.
var approaching_move_speed = 80
var chase_distance_threshold = 300000


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	super()
	# Load node references
	n_scene = get_tree().current_scene
	n_toprays = get_node("TopRays").get_children()
	n_bottomrays = get_node("BottomRays").get_children()
	n_sprite = get_node("Sprite")
	
	# Initialize state
	animation_frame = Time.get_ticks_msec() + animation_frame_duration


func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	# Animation code
	if current_time > animation_frame:
		n_sprite.frame = 0 if n_sprite.frame == 3 else n_sprite.frame + 1
		animation_frame = current_time + animation_frame_duration

	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)
	
	# If not yet awaken
	if n_player == null:
		return

	# Behavior code
	var difference = n_player.global_position - global_position
	var difference_mag = difference.length()
	var move
	if difference_mag > desired_distance:
		move = difference / difference_mag
	else:
		move = -difference / difference_mag
	
	if state == STATE.COOLING:
		# After attack, return form, idle
		if current_time <= state_frame:
			scale.y = 1 - (state_frame - current_time) / (2 * cooling_duration)
			scale.x = 1 + (state_frame - current_time) / (2 * cooling_duration)
			print(scale)
		else:
			scale.y = 1
			scale.x = 1
			state = STATE.APPROACHING
			state_frame = current_time + approaching_duration
		velocity = lerp(velocity, Vector2.ZERO, acceleration * delta)
	elif state == STATE.APPROACHING:
		# After idle, rearm, quickly reposition
		if difference_mag > chase_distance_threshold:
			n_navagent.target_position = n_player.global_position
			velocity = (n_navagent.get_next_path_position() - position).normalized() * approaching_move_speed
		else:
			if current_time > state_frame and difference_mag < desired_distance:
				state = STATE.CHARGING
				state_frame = current_time + attack_duration
			velocity = lerp(velocity, move * approaching_move_speed, acceleration * delta)
	else:
		# Prepare for fire, slowly position
		if current_time > state_frame:
			# Attack
			var n_fireballs = [ null, null, null ]
			for i in range(3):
				n_fireballs[i] = p_Fireball.instantiate()
			var flag = true
			for n_ray in n_toprays:
				if n_ray.get_collider():
					flag = false
					break
			if flag:
				n_fireballs[0].position = position + Vector2(0, -80)
				n_fireballs[1].position = position + Vector2(-40, -60)
				n_fireballs[2].position = position + Vector2(40, -60)
			else:
				for n_ray in n_bottomrays:
					if n_ray.get_collider():
						flag = true
						break
				if not flag:
					n_fireballs[0].position = position + Vector2(0, 40)
					n_fireballs[1].position = position + Vector2(-40, 30)
					n_fireballs[2].position = position + Vector2(40, 30)
				else:
					if n_player.global_position.x < global_position.x:
						n_fireballs[0].position = position + Vector2(-20, 60)
						n_fireballs[1].position = position + Vector2(-30, 40)
						n_fireballs[2].position = position + Vector2(-20, 20)
					else:
						n_fireballs[0].position = position + Vector2(20, 60)
						n_fireballs[1].position = position + Vector2(30, 40)
						n_fireballs[2].position = position + Vector2(20, 20)


			for i in range(3):
				n_fireballs[i].velocity = fireball_speed * (n_player.global_position \
						- n_fireballs[i].global_position).normalized()
				n_scene.add_child(n_fireballs[i])

			state = STATE.COOLING
			state_frame = current_time + cooling_duration
		else:
			scale.y = .5 + (state_frame - current_time) / (2 * attack_duration)
			scale.x = 1.5 - (state_frame - current_time) / (2 * attack_duration)
		velocity = lerp(velocity, move * charging_move_speed, acceleration * delta)
	move_and_slide()
	
	n_sprite.scale.x = 3 if global_position.x < n_player.global_position.x else -3
