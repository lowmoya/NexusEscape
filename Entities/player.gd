extends Entity

enum {SWORD_WE, GUN_WE, COUNT_WE}
var held = null
var weapons = [ null , null]
@export var weapon = SWORD_WE

@export var speed = 340
@export var acceleration = 90
var movement = Vector2.ZERO



func updateHeld():
	var offset = get_viewport().get_mouse_position() - global_position
	held.rotation = atan(offset.y / offset.x)
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
	updateHeld()

	weapons[SWORD_WE] = held.get_node("Sword")
	weapons[GUN_WE] = held.get_node("Gun")


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
			weapons[weapon].attack()
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
