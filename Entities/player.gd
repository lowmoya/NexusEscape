extends Entity

enum {SWORD_WE, GUN_WE, COUNT_WE}
var held = null
var weapons = [ null , null]
@export var max_energy = 10.
var energy = max_energy
@export var weapon = SWORD_WE

@export var speed = 340
@export var acceleration = 10
var movement = Vector2.ZERO

var time_last = Time.get_ticks_msec()


func updateHeld():
	var offset = get_local_mouse_position()
	held.rotation = atan(offset.y / offset.x)
	
	var time_now = Time.get_ticks_msec()
	weapons[weapon].tick(float(time_now - time_last) / 1000.)
	time_last = time_now	
	
	if not weapons[weapon].idle:
		if offset.x < 0:
			held.rotation += PI
		return
	
	if offset.x < 0:
		held.rotation += PI
		held.scale.y = -1
	else:
		held.scale.y = 1


func switchHeld(index):
	weapons[weapon].visible = false
	weapon = index
	weapons[weapon].visible = true


func _ready():
	held = get_node("Held")
	health = max_health
	energy = max_energy

	weapons[SWORD_WE] = held.get_node("Sword")
	weapons[GUN_WE] = held.get_node("Gun")
	
	updateHeld()


func _process(_delta):
	if defeated:
		get_tree().change_scene_to_file("mainmenu.tscn")
	
	movement = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		) * speed;
	if movement.x != 0 and movement.y != 0:
		movement *= .71

	if weapons[weapon].idle:
		if Input.is_action_just_pressed("attack_main"):
			if energy >= weapons[weapon].energy_cost:
				weapons[weapon].attack()
				energy -= weapons[weapon].energy_cost
		elif Input.is_action_just_pressed("select_one"):
			switchHeld(SWORD_WE)
		elif Input.is_action_just_pressed("select_two"):
			switchHeld(GUN_WE)
		elif Input.is_action_just_pressed("select_right"):
			switchHeld(0 if weapon == COUNT_WE - 1 else weapon + 1)
		elif Input.is_action_just_pressed("select_left"):
			switchHeld(COUNT_WE - 1 if weapon == 0 else weapon - 1)


func _physics_process(delta):
	velocity = lerp(velocity, movement, acceleration * delta)
	move_and_slide()
	updateHeld()
