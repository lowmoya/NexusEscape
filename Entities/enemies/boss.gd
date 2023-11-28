extends Entity

# Body Variables
@export var n_sprite: Sprite2D
const ANIMATION_FRAME_DURATION: float = .1
const ANIMATION_FRAMES: int = 3
var animation_frame: float

const desired_distance: float = 6.e2
const speed: float = 250.
const acceleration: float = .99

# Weapon variables
const WEAPON_SWITCH_DELAY: float = 2.
const WEAPON_SWITCH_LIGHT: float = 18.
var weapon_switch_time
@export var n_held: Node2D

@export var n_sword: Node2D
@export var n_sword_collider: CollisionPolygon2D
@export var n_sword_light: PointLight2D
enum SwordAttacks { SLASH_RIGHT, SLASH_LEFT, STAB }
enum SwordStates { ROTATE, SHIFT, ORIENT, DISABLE_COLLIDER, TOGGLE_FOLLOW, WAIT }

const SWORD_ACT_SHIFT_SPEED: float = 800.
const SWORD_ANT_SHIFT_SPEED: float = 450.
const SWORD_ACT_ROTATE_SPEED: float = 5.
const SWORD_ANT_ROTATE_SPEED: float = 1.5

const SWORD_IDLE_DURATION = 1.

const SWORD_HOLSTER_DISTANCE = 200.
const SWORD_WITHDRAW_DISTANCE = 100.

const SWORD_LS_START_ANGLE = -PI
const SWORD_LS_ANTIC_ANGLE = -9. * PI / 8.
const SWORD_RS_START_ANGLE = 0.
const SWORD_RS_ANTIC_ANGLE = PI / 8.
const SWORD_ST_ANGLE = -PI / 2.

var sword_states = []
var last_sword_attack: SwordAttacks = SwordAttacks.SLASH_LEFT
var sword_rotation = 0.
var last_player_rotation = 0.
var follow_player = true

@export var n_gun: Sprite2D
@export var n_gun_light: PointLight2D

@export var n_coil: Sprite2D
@export var n_coil_light: PointLight2D


# maybe sword and gun follow ish the player but electric is just from the center and flies up before landing in the center
# State Variables
enum Phases { IDLE = -1, SWORD, GUN, ELECTRIC }
var phase: Phases = Phases.IDLE
var fire_shield: float = 100.
var electric_shield: float = 100.


# Condition Constants
const AWAKEN_SDT: float = 3.5e5

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get references
	n_player = get_tree().current_scene.get_node("Player")
	
	var current_time = Time.get_ticks_msec() / 1.e3

	# Prepare animation components
	animation_frame = current_time + ANIMATION_FRAME_DURATION

	# Prepare state componensts
	health = 100.


func sword_phase(delta, to_player, to_player_d):
	# hold desired player distance
	to_player_d += 30
	if sword_states.is_empty():
		if randi_range(0, 1) == 1:
			# Slash
			if last_sword_attack == SwordAttacks.STAB:
				# Move to one of the slash positions
				last_sword_attack = randi_range(0, 1)
				if last_sword_attack == SwordAttacks.SLASH_LEFT:
					sword_states.append([SwordStates.ORIENT, 1])
					sword_states.append([SwordStates.ROTATE, (SWORD_RS_START_ANGLE - \
						SWORD_ST_ANGLE) / SWORD_ANT_ROTATE_SPEED, SWORD_RS_START_ANGLE, \
						-SWORD_ANT_ROTATE_SPEED])
				else:
					sword_states.append([SwordStates.ORIENT, -1])
					sword_states.append([SwordStates.ROTATE, (SWORD_ST_ANGLE - \
						SWORD_LS_START_ANGLE) / SWORD_ANT_ROTATE_SPEED, SWORD_LS_START_ANGLE, \
						SWORD_ANT_ROTATE_SPEED])
			if last_sword_attack == SwordAttacks.SLASH_LEFT:
				# Queue up a right slash
				sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_HOLSTER_DISTANCE) / \
						SWORD_ANT_SHIFT_SPEED, to_player_d, SWORD_ANT_SHIFT_SPEED])
				sword_states.append([SwordStates.ROTATE, (SWORD_RS_ANTIC_ANGLE - \
						SWORD_RS_START_ANGLE) / SWORD_ANT_ROTATE_SPEED, SWORD_RS_ANTIC_ANGLE, \
						-SWORD_ANT_ROTATE_SPEED])
				sword_states.append([SwordStates.TOGGLE_FOLLOW])
				sword_states.append([SwordStates.DISABLE_COLLIDER, false])
				sword_states.append([SwordStates.ROTATE, (SWORD_RS_ANTIC_ANGLE - \
						SWORD_LS_START_ANGLE) / SWORD_ACT_ROTATE_SPEED, SWORD_LS_START_ANGLE, \
						SWORD_ACT_ROTATE_SPEED])
				sword_states.append([SwordStates.DISABLE_COLLIDER, true])
				sword_states.append([SwordStates.ORIENT, -1])
				sword_states.append([SwordStates.TOGGLE_FOLLOW])
				sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_HOLSTER_DISTANCE) / \
						SWORD_ANT_SHIFT_SPEED, SWORD_HOLSTER_DISTANCE, -SWORD_ANT_SHIFT_SPEED])
				last_sword_attack = SwordAttacks.SLASH_RIGHT
			else:
				# Queue up a left slash
				sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_HOLSTER_DISTANCE) / \
						SWORD_ANT_SHIFT_SPEED, to_player_d, SWORD_ANT_SHIFT_SPEED])
				sword_states.append([SwordStates.ROTATE, (SWORD_LS_START_ANGLE - \
						SWORD_LS_ANTIC_ANGLE) / SWORD_ANT_ROTATE_SPEED, SWORD_LS_ANTIC_ANGLE, \
						SWORD_ANT_ROTATE_SPEED])
				sword_states.append([SwordStates.TOGGLE_FOLLOW])
				sword_states.append([SwordStates.DISABLE_COLLIDER, false])
				sword_states.append([SwordStates.ROTATE, (SWORD_RS_START_ANGLE - \
						SWORD_LS_ANTIC_ANGLE) / SWORD_ACT_ROTATE_SPEED, SWORD_RS_START_ANGLE, \
						-SWORD_ACT_ROTATE_SPEED])
				sword_states.append([SwordStates.DISABLE_COLLIDER, true])
				sword_states.append([SwordStates.ORIENT, 1])
				sword_states.append([SwordStates.TOGGLE_FOLLOW])
				sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_HOLSTER_DISTANCE) / \
						SWORD_ANT_SHIFT_SPEED, SWORD_HOLSTER_DISTANCE, -SWORD_ANT_SHIFT_SPEED])
				last_sword_attack = SwordAttacks.SLASH_LEFT
		else: # STAB
			# Queue up move to stab position if in one of the slash positions
			if last_sword_attack == SwordAttacks.SLASH_LEFT:
				sword_states.append([SwordStates.ROTATE, (SWORD_RS_START_ANGLE - SWORD_ST_ANGLE) /\
						SWORD_ANT_ROTATE_SPEED, SWORD_ST_ANGLE, SWORD_ANT_ROTATE_SPEED])
			elif last_sword_attack == SwordAttacks.SLASH_RIGHT:
				sword_states.append([SwordStates.ROTATE, (SWORD_ST_ANGLE - SWORD_LS_START_ANGLE) /\
						SWORD_ANT_ROTATE_SPEED, SWORD_ST_ANGLE, -SWORD_ANT_ROTATE_SPEED])

			# Queue up stab
			sword_states.append([SwordStates.SHIFT,  (SWORD_HOLSTER_DISTANCE - \
					SWORD_WITHDRAW_DISTANCE) / SWORD_ANT_SHIFT_SPEED, SWORD_WITHDRAW_DISTANCE, \
					-SWORD_ANT_SHIFT_SPEED])
			sword_states.append([SwordStates.TOGGLE_FOLLOW])
			sword_states.append([SwordStates.DISABLE_COLLIDER, false])
			sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_WITHDRAW_DISTANCE) / \
					SWORD_ACT_SHIFT_SPEED, to_player_d, SWORD_ACT_SHIFT_SPEED])
			sword_states.append([SwordStates.DISABLE_COLLIDER, true])
			sword_states.append([SwordStates.SHIFT,  (to_player_d - SWORD_HOLSTER_DISTANCE) / \
					SWORD_ACT_SHIFT_SPEED, SWORD_HOLSTER_DISTANCE, -SWORD_ACT_SHIFT_SPEED])
			sword_states.append([SwordStates.TOGGLE_FOLLOW])
			last_sword_attack = SwordAttacks.STAB
		# Queue up after attack idle
		sword_states.append([SwordStates.WAIT, SWORD_IDLE_DURATION])

	# Process queue
	match sword_states[0][0]:
		SwordStates.ROTATE:
			# [1] duration in seconds always positive
			# [2] end rotation (subtract PI from whatever it would normally be)
			# [3] speed (positive ccw negative cw)
			sword_states[0][1] -= delta
			sword_rotation = sword_states[0][2]
			if sword_states[0][1] > 0:
				sword_rotation += sword_states[0][3] * sword_states[0][1]
			else:
				sword_states.pop_front()
		SwordStates.SHIFT:
			# [1] duration in seconds always positive
			# [2] end distance (always positive, bigger the further from the boss)
			# [3] speed (positive is away from boss, negative towards boss
			sword_states[0][1] -= delta
			n_sword.position.x = -sword_states[0][2]
			if sword_states[0][1] > 0:
				n_sword.position.x += sword_states[0][3] * sword_states[0][1]
			else:
				sword_states.pop_front()
		SwordStates.ORIENT:
			# [1] -1 blade ccw
			#	   1 blade cw
			n_sword.scale.y = sword_states[0][1]
			sword_states.pop_front()
		SwordStates.DISABLE_COLLIDER:
			n_sword_collider.disabled = sword_states[0][1]
			sword_states.pop_front()
		SwordStates.TOGGLE_FOLLOW:
			if follow_player:
				follow_player = false
				last_player_rotation = atan2(to_player.y, to_player.x) - PI / 2.
			else:
				follow_player = true
			sword_states.pop_front()
		SwordStates.WAIT:
			# [1] seconds
			sword_states[0][1] -= delta
			if sword_states[0][1] < 0:
				sword_states.pop_front()
	if follow_player:
		n_held.rotation = sword_rotation + atan2(to_player.y, to_player.x) - PI / 2.
		velocity = lerp(velocity, to_player / to_player_d * clamp(\
				to_player_d - desired_distance, -speed, speed),
				acceleration * delta)
		move_and_slide()
	else:
		n_held.rotation = sword_rotation + last_player_rotation
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get common variables
	var current_time = Time.get_ticks_msec() / 1.e3
	var to_player = n_player.position - position
	var to_player_sd = to_player.x ** 2 + to_player.y ** 2
	var to_player_d = sqrt(to_player_sd)
	
	# Handle animations
	if current_time > animation_frame:
		n_sprite.frame_coords.x = n_sprite.frame_coords.x + 1 if n_sprite.frame_coords.x + 1 < \
				ANIMATION_FRAMES else 0
		animation_frame = current_time + ANIMATION_FRAME_DURATION
	

	# Handle phase behaviors
	match phase:
		Phases.SWORD:
			sword_phase(delta, to_player, to_player_d)
		Phases.GUN:
			pass
		Phases.ELECTRIC:
			pass
		_: # Phases.IDLE
			if to_player_sd < AWAKEN_SDT:
				phase = Phases.SWORD
				n_sword.visible = true
	

func damage(amount):
	match phase:
		Phases.SWORD:
			fire_shield -= amount
			if fire_shield <= 0:
				fire_shield = 0
				phase = Phases.GUN
				n_sword.visible = false
				n_gun.visible = true
		Phases.GUN:
			electric_shield -= amount
			if electric_shield <= 0:
				electric_shield = 0
				phase = Phases.ELECTRIC
				n_gun.visible = false
				n_coil.visible = true
		Phases.ELECTRIC:
			health -= amount
			if health <= 0:
				health = 0
				queue_free()
				n_coil.visible = false
				# can add a death phase



func _on_sword_hit_area_body_entered(body):
	body.damage(3.)
	body.velocity += (body.global_position - n_sword.global_position).normalized() * 2000.
	n_sword_collider.set_deferred('disabled', true)
