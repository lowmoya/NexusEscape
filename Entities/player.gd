extends Entity



# ################################################## #
# Enums                                              #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

enum WeaponType {SWORD = 0, GUN, COUNT}



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

# weapons
@export var weapon = WeaponType.SWORD
var n_held = null
var n_weapons = [ ]

# resources
@export var max_energy = 10.
var energy = 0

# movement
@export var speed = 340
@export var acceleration = 10
var movement = Vector2.ZERO



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Obtain references to weapon / hand related nodes
	n_held = get_node("Held")
	n_weapons.resize(WeaponType.COUNT)
	n_weapons[WeaponType.SWORD] = n_held.get_node("Sword")
	n_weapons[WeaponType.GUN] = n_held.get_node("Gun")
	
	# Set default variables
	health = max_health
	energy = max_energy
	
	# Update the hand angle
	updateHeld(0)


func _physics_process(delta):
	# Ensure the player is still alive or handle otherwise
	if defeated:
		get_tree().change_scene_to_file("res://Levels/mainmenu.tscn")
	
	# Obtain the players desired direction 
	movement = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		) * speed;
	if movement.x != 0 and movement.y != 0:
		movement *= .71
	
	# Process weapon related inputs
	if n_weapons[weapon].idle:
		if Input.is_action_just_pressed("attack_main"):
			if energy >= n_weapons[weapon].energy_cost:
				n_weapons[weapon].attack()
				energy -= n_weapons[weapon].energy_cost
		elif Input.is_action_just_pressed("select_one"):
			switchHeld(0)
		elif Input.is_action_just_pressed("select_two"):
			switchHeld(1)
		elif Input.is_action_just_pressed("select_right"):
			switchHeld(0 if weapon == WeaponType.COUNT - 1 else weapon + 1)
		elif Input.is_action_just_pressed("select_left"):
			switchHeld(WeaponType.COUNT - 1 if weapon == 0 else weapon - 1)
		
	# Move velocity "towards" the players desired direction and move
	velocity = lerp(velocity, movement, acceleration * delta)
	move_and_slide()
	
	# Update the hand angle and call the current weapons phys tick
	updateHeld(delta)



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
	# Toggle last and new weapons visibility and update the weapon index
	n_weapons[weapon].visible = false
	weapon = index
	n_weapons[weapon].visible = true



