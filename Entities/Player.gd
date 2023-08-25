extends CharacterBody2D

enum {SWORD_WE, GUN_WE}
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


func _ready():
	held = get_node("Held")
	updateHeld()

	weapons[SWORD_WE] = get_node("Held/Sword")


func _process(_delta):
	movement = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		) * speed;
	if movement.x != 0 and movement.y != 0:
		movement *= .71
	
	if Input.is_action_just_pressed("attack_main") and weapons[weapon].idle:
		weapons[weapon].attack()


func _physics_process(delta):
	velocity = lerp(velocity, movement, acceleration * delta)
	move_and_slide()
	updateHeld()
