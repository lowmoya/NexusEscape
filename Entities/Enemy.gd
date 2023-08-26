extends CharacterBody2D

@export var acceleration = 10
@export var speed = 100

var held = null
var weapon = null
var player = null

var delay = .5 

func _ready():
	held = get_node("Held")
	weapon = held.get_node("Gun")
	player = get_tree().current_scene.get_node("Scene/Player")



func _physics_process(delta):
	var move = Vector2(player.velocity + player.global_position - global_position)
	velocity = lerp(velocity, move / sqrt(move.x * move.x + move.y * move.y) * speed, acceleration * delta)
	move_and_slide()
	var aim_offset = player.global_position - global_position
	held.rotation = atan(aim_offset.y / aim_offset.x)
	if aim_offset.x < 0:
		held.scale.x = -1
	else:
		held.scale.x = 1
	
	delay -= delta
	if delay <= 0:
		weapon.attack()
		delay = 1
