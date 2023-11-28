extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 200
@export var attack_delay = .5
@export var knockback = 600

# Animation variables
@export var n_navagent: NavigationAgent2D
@export var n_sprite: Sprite2D
@export var n_sword: Node2D

const animation_frames = 6
const animation_duration = 2e2
var animation_frame

# Dashing variables
enum DashStates { IDLE = 0, ANTICIPATION, FOLLOW_THROUGH };
const dash_durations =  [ 200., 1000., 2000. ]
var dash_state = DashStates.IDLE
var dash_frame
const desired_squared_distance = 1e4
const dash_start_distance_threshold = 9e4
const dash_cancel_distance_threshold = 6e4
const chase_distance_threshold = 300000
const dash_strength = 1200
const dash_scale = .2
var normal_scaling = Vector2(scale.x, scale.y)

# Attack variables
@export var n_sword_sprite: Sprite2D
var n_sword_sprite_shader: ShaderMaterial
@export var n_sword_collider: CollisionPolygon2D
@export var n_sword_light: PointLight2D
enum AttackStates { IDLE, ANTICIPATION, ACTION, FOLLOW_THROUGH }
var attack_durations = [ 1e3, 1e3, 1e2, 4e2 ]
var attack_state = AttackStates.IDLE
var attack_frame0 = 0.
var attack_frame1 = 0.

const sword_sprite_rx = 70
const sword_sprite_lx = -80
var current_attack_delay = 0 



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	super()
	n_sword_sprite_shader = ShaderMaterial.new()
	n_sword_sprite_shader.shader = (n_sword_sprite.material as ShaderMaterial).shader
	n_sword_sprite.material = n_sword_sprite_shader
	current_attack_delay = attack_delay
	animation_frame = Time.get_ticks_msec() + animation_duration
	dash_frame = Time.get_ticks_msec() + 1000


func _physics_process(delta):
	# If should just idle
	if n_player == null:
		return
	
	# Regularly accessed variables
	var player_offset =  n_player.global_position - global_position
	var squared_player_distance = player_offset.x ** 2 + player_offset.y ** 2
	var current_time = Time.get_ticks_msec()
	
	# Animation
	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)
	n_sword_sprite_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)
	
	if current_time > animation_frame:
		n_sprite.frame = n_sprite.frame + 1 if n_sprite.frame < animation_frames - 1 else 0
		animation_frame = current_time + animation_duration
	
	# Handle the dashing
	match dash_state:
		DashStates.ANTICIPATION:
			if current_time > dash_frame:
				dash_state = DashStates.FOLLOW_THROUGH
				dash_frame = current_time + dash_durations[DashStates.FOLLOW_THROUGH]
			elif squared_player_distance < dash_cancel_distance_threshold:
				dash_state = DashStates.IDLE
				dash_frame = current_time + dash_durations[DashStates.IDLE]
				scale = normal_scaling
			else:
				var portion = 1 - (dash_frame - current_time) / \
						dash_durations[DashStates.ANTICIPATION]
				scale.x = normal_scaling.x + portion * dash_scale
				scale.y = normal_scaling.y - portion * dash_scale
		DashStates.FOLLOW_THROUGH:
			if current_time > dash_frame or squared_player_distance < \
						dash_cancel_distance_threshold:
				dash_state = DashStates.IDLE
				dash_frame = current_time + dash_durations[DashStates.IDLE]
				scale = normal_scaling
			else:
				var portion = (dash_frame - current_time) / \
						dash_durations[DashStates.FOLLOW_THROUGH]
				scale.x = normal_scaling.x + portion * dash_scale
				scale.y = normal_scaling.y - portion * dash_scale
		_: # DashStates.IDLE
			if squared_player_distance > dash_start_distance_threshold:
				dash_state = DashStates.ANTICIPATION
				dash_frame = current_time + dash_durations[DashStates.ANTICIPATION]
			
	# Choose direct movement or pathing
	if squared_player_distance < chase_distance_threshold:
		var max_speed = speed
		if dash_state == DashStates.FOLLOW_THROUGH:
			max_speed += dash_strength
		velocity = lerp(velocity, player_offset / sqrt(squared_player_distance) * clamp(\
				squared_player_distance - desired_squared_distance, -max_speed, max_speed),
				acceleration * delta)
	else:
		n_navagent.target_position = n_player.global_position
		velocity = (n_navagent.get_next_path_position() - position).normalized() * (speed + \
				(dash_strength if dash_state == DashStates.FOLLOW_THROUGH else 0))

	# Adjust for facing direction
	if n_player.global_position.x < global_position.x:
		n_sprite.scale.x = -4
		n_sword.scale.x = -1
		n_sword.position.x = sword_sprite_lx
		n_sword.z_index = 0
	else:
		n_sprite.scale.x = 4
		n_sword.scale.x = 1
		n_sword.position.x = sword_sprite_rx
		n_sword.z_index = -1
	
	# Handle attacking
	match attack_state:
		AttackStates.ANTICIPATION:
			if current_time > attack_frame0:
				attack_state = AttackStates.ACTION
				attack_frame0 = current_time + attack_durations[AttackStates.ACTION]
				n_sword_sprite.frame_coords.x = 0
				n_sword_sprite.frame_coords.y = AttackStates.ACTION
				n_sword_collider.disabled = false
				n_sword_light.energy = 2.
				n_sword_sprite_shader.set_shader_parameter("blue_factor", 2.)
			else:
				if current_time > attack_frame1 and n_sword_sprite.frame_coords.x == 0:
					n_sword_sprite.frame_coords.x = 1
				var portion = 2. -  2 * (attack_frame0 - current_time) / \
						attack_durations[AttackStates.ANTICIPATION]
				n_sword_light.energy = portion
				n_sword_sprite_shader.set_shader_parameter("blue_factor", portion)
		AttackStates.ACTION:
			if current_time > attack_frame0:
				attack_state = AttackStates.FOLLOW_THROUGH
				attack_frame0 = current_time + attack_durations[AttackStates.FOLLOW_THROUGH]
				attack_frame1 = current_time + attack_durations[AttackStates.FOLLOW_THROUGH] / 2.
				n_sword_sprite.frame_coords.y = AttackStates.FOLLOW_THROUGH
				n_sword_collider.disabled = true
		AttackStates.FOLLOW_THROUGH:
			if current_time > attack_frame0:
				attack_state = AttackStates.IDLE
				attack_frame0 = current_time + attack_durations[AttackStates.IDLE]
				n_sword_sprite.frame_coords.x = 0
				n_sword_sprite.frame_coords.y = AttackStates.IDLE
				n_sword_collider.disabled = true
				n_sword_light.energy = .0
				n_sword_sprite_shader.set_shader_parameter("blue_factor", .0)
			else:
				if current_time > attack_frame1 and n_sword_sprite.frame_coords.x == 0:
					n_sword_sprite.frame_coords.x = 1
				var portion = 2 * (attack_frame0 - current_time) / \
						attack_durations[AttackStates.FOLLOW_THROUGH]
				n_sword_light.energy = portion
				n_sword_sprite_shader.set_shader_parameter("blue_factor", portion)
		_: # AttackStates.IDLE
			if current_time > attack_frame0 and dash_state == DashStates.IDLE:
				attack_state = AttackStates.ANTICIPATION
				attack_frame0 = current_time + attack_durations[AttackStates.ANTICIPATION]
				attack_frame1 = current_time + attack_durations[AttackStates.ANTICIPATION] / 2.
				n_sword_sprite.frame_coords.y = AttackStates.ANTICIPATION
	
	move_and_slide()



func _on_sword_area_body_entered(body):
	body.damage(3)
	body.velocity += knockback * (body.global_position - global_position).normalized()
	n_sword_collider.disabled = true
