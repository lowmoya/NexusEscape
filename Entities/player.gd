extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

# weapons
@export var weapon = Weapon.WeaponType.Fist
var n_held = null
var n_weapons = [ ]

# audio
enum AudioLabel { Damaged = 0, Dash, Dodge, Footstep0, Footstep1, Footstep2, GameOver, SwitchHeld, Count }
var n_audioplayer = null
var audiosamples = []

# sprite
enum SpriteLabel { Damaged = 0, Attack, DashHold, Dash, WalkRight, WalkLeft, Idle }
@export var dash_sprites = 8.
@export var hurt_sprite_extra_delay = 150.
@export var walk_sprites = 15
@export var walk_sprites_per_second = 30
var n_sprite = null
var walk_sprite = 0.

# resources
@export var max_energy = 10.
var energy = 0

# movement
@export var speed = 340
@export var acceleration = 10
@export var dash_delay = 3000.
@export var dash_start_delay = 200.
@export var dash_length = 800.
@export var dash_strength = 400
var movement = Vector2.ZERO
var dash_frame = 0
var dash_start = dash_delay - dash_start_delay
var dash_end = dash_start - dash_length



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Obtain references to weapon / hand related nodes
	n_held = get_node("Held")
	n_weapons.resize(Weapon.WeaponType.Count)
	n_weapons[Weapon.WeaponType.Fist] = n_held.get_node("Fist")
	n_weapons[Weapon.WeaponType.Sword] = n_held.get_node("Sword")
	n_weapons[Weapon.WeaponType.Gun] = n_held.get_node("Gun")

	# Obtain references to audio player and streams
	n_audioplayer = get_node("AudioPlayer")
	audiosamples.resize(AudioLabel.Count)
	audiosamples[AudioLabel.Damaged] = load("res://Resources/Sound Effects/player movement/damage_taken.wav")
	audiosamples[AudioLabel.GameOver] = load("res://Resources/Sound Effects/player movement/game_over.wav")
	audiosamples[AudioLabel.SwitchHeld] = load("res://Resources/Sound Effects/player weapons/switch_weapon.wav")
	
	# Obtain references to sprite
	n_sprite = get_node("Sprite")
	
	# Set default variables
	health = max_health
	energy = max_energy
	
	# Update the hand angle
	updateHeld(0)


func _physics_process(delta):
	# Ensure the player is still alive or handle otherwise
	if defeated:
		n_audioplayer.stream = audiosamples[AudioLabel.GameOver]
		n_audioplayer.play()
		get_tree().change_scene_to_file("res://Levels/mainmenu.tscn")
	
	# Obtain the players desired direction 
	movement = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		);
	if movement.x != 0 and movement.y != 0:
		movement *= .71
	
	# Record time of this frame for reference throughout
	var current_time = Time.get_ticks_msec()
	
	# Multliply by speed, include dash strength if in boost part of dash frame
	movement *= speed if current_time > dash_frame - dash_end or current_time <= dash_frame - dash_start else speed + dash_strength
	
	
	# Process non-weapon related inputs
	if Input.is_action_just_pressed("dash"):
		if current_time <= dash_frame:
			pass # Play audio here
		else:
			dash_frame = current_time + dash_delay
		
	# Process weapon related inputs
	if n_weapons[weapon].idle:
		if Input.is_action_just_pressed("attack_main"):
			if energy >= n_weapons[weapon].energy_cost:
				n_weapons[weapon].attack()
				energy -= n_weapons[weapon].energy_cost
		if Input.is_action_just_pressed("select_one"):
			switchHeld(0)
		elif Input.is_action_just_pressed("select_two"):
			switchHeld(1)
		elif Input.is_action_just_pressed("select_three"):
			switchHeld(2)
		elif Input.is_action_just_pressed("select_right"):
			switchHeld(0 if weapon == Weapon.WeaponType.Count - 1 else weapon + 1)
		elif Input.is_action_just_pressed("select_left"):
			switchHeld(Weapon.WeaponType.Count - 1 if weapon == 0 else weapon - 1)
	
	# Move velocity "towards" the players desired direction and move
	velocity = lerp(velocity, movement, acceleration * delta)
	move_and_slide()
	
	# Set animation
	if current_time <= invincibility_frame + hurt_sprite_extra_delay:
		n_sprite.scale.x = -3 if velocity.x < 0 else 3
		n_sprite.frame_coords = Vector2(0, SpriteLabel.Damaged)
	elif current_time <= dash_frame - dash_end:
		# Dash animation
		n_sprite.scale.x = -3 if velocity.x < 0 else 3
		if n_sprite.frame_coords.y != SpriteLabel.Dash:
			n_sprite.frame_coords = Vector2(0, SpriteLabel.Dash)
		elif dash_frame - current_time >= dash_start:
			n_sprite.frame_coords.x = (1. - ((dash_frame - dash_start - current_time) / dash_start_delay)) * dash_sprites
		else:
			n_sprite.frame_coords.x = dash_sprites
	elif velocity.x * velocity.x + velocity.y * velocity.y > 600:
		# Walk animation
		if n_sprite.frame_coords.y != SpriteLabel.WalkLeft and n_sprite.frame_coords.y != SpriteLabel.WalkRight:
			n_sprite.frame_coords = Vector2(0, SpriteLabel.WalkLeft if velocity.x < 0 else \
					SpriteLabel.WalkRight)
			n_sprite.scale.x = 3
			walk_sprite = 0.
		else:
			n_sprite.frame_coords = Vector2(floor(walk_sprite), SpriteLabel.WalkLeft if \
					velocity.x < 0 else SpriteLabel.WalkRight)
			walk_sprite += delta * walk_sprites_per_second
			if walk_sprite >= walk_sprites:
				walk_sprite -= walk_sprites
	elif n_sprite.frame_coords.y != SpriteLabel.Idle:
		# Idle animation
		n_sprite.frame_coords = Vector2(0, SpriteLabel.Idle)
		n_sprite.scale.x = -3 if velocity.x < 0 else 3
	
	# Update the hand angle and call the current weapons phys tick
	updateHeld(delta)



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func damage(amount):
	super(amount)
	n_audioplayer.stream = audiosamples[AudioLabel.Damaged]
	n_audioplayer.play()
	


# ################################################## #
# Utility Functions                                  #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func updateHeld(delta):
	# Call the weapons physics process and update time reference for delta
	n_weapons[weapon].tick(delta)
	
	# Set the weapons rotation to orient towards the cursor
	var cursor_offset = get_local_mouse_position()
	n_held.rotation = atan2(cursor_offset.y, cursor_offset.x)
	
	# Update the weapons flip if not attacking
	if n_weapons[weapon].idle:
		n_held.scale.y = -1 if cursor_offset.x < 0 else 1


func switchHeld(index):
	if index == weapon:
		return
	
	# Toggle last and new weapons visibility and update the weapon index
	n_weapons[weapon].visible = false
	weapon = index
	n_weapons[weapon].visible = true
	
	# Play sound
	n_audioplayer.stream = audiosamples[AudioLabel.SwitchHeld]
	n_audioplayer.play()
