extends Node2D

var container = null

@export var speed = 4 * PI
var angle = -PI / 2
var clockwise = true


func _ready():
	container = get_node("HitArea")
	if get_viewport().get_mouse_position().x < global_position.x:
		speed *= -1
		angle *= -1
		clockwise = false
	container.rotation = angle

func _physics_process(delta):
	angle += speed * delta
	if clockwise:
		if angle >= PI / 2:
			queue_free()
	else:
		if angle <= -PI / 2:
			queue_free();
	container.rotation = angle
