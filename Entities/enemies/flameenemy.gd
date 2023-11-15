extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var desired_distance = 500

var n_scene = null
var n_sprite = null
var n_player = null
var p_Fireball = preload("res://Weapons/Projectiles/fireball.tscn")
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


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_scene = get_tree().current_scene
	n_sprite = get_node("Sprite")
	n_player = get_tree().current_scene.get_node("Player")
	
	# Initialize state
	health = max_health
	animation_frame = Time.get_ticks_msec() + animation_frame_duration


func _physics_process(delta):
	var current_time = Time.get_ticks_msec()
	# Animation code
	if current_time > animation_frame:
		n_sprite.frame = 0 if n_sprite.frame == 3 else n_sprite.frame + 1
		animation_frame = current_time + animation_frame_duration

	

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
		if current_time > state_frame and difference_mag < desired_distance:
			state = STATE.CHARGING
			state_frame = current_time + attack_duration
		velocity = lerp(velocity, move * approaching_move_speed, acceleration * delta)
	else:
		# Prepare for fire, slowly position
		if current_time > state_frame:
			# Attack
			var n_fireball0 = p_Fireball.instantiate()
			n_fireball0.position = position + Vector2(0, -80)
			n_fireball0.velocity = fireball_speed * (n_player.global_position \
					- n_fireball0.global_position).normalized()
			var n_fireball1 = p_Fireball.instantiate()
			n_fireball1.position = position + Vector2(-40, -60)
			n_fireball1.velocity = fireball_speed * (n_player.global_position \
					- n_fireball1.global_position).normalized()
			var n_fireball2 = p_Fireball.instantiate()
			n_fireball2.position = position + Vector2(40, -60)
			n_fireball2.velocity = fireball_speed * (n_player.global_position \
					- n_fireball2.global_position).normalized()


			n_scene.add_child(n_fireball0)
			n_scene.add_child(n_fireball1)
			n_scene.add_child(n_fireball2)

			state = STATE.COOLING
			state_frame = current_time + cooling_duration
		else:
			scale.y = .5 + (state_frame - current_time) / (2 * attack_duration)
			scale.x = 1.5 - (state_frame - current_time) / (2 * attack_duration)
		velocity = lerp(velocity, move * charging_move_speed, acceleration * delta)
	move_and_slide()
	
	n_sprite.scale.x = 3 if global_position.x < n_player.global_position.x else -3
