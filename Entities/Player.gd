extends CharacterBody2D

@export var Sword = preload("res://Prefabs/sword.tscn")
var sword = null

@export var speed = 360
@export var acceleration = 90
var movement = Vector2.ZERO

func updateSword():
	sword.position = position
	var offset = get_viewport().get_mouse_position() - global_position
	sword.rotation = tanh(offset.y / offset.x) if offset.x > 0 else tanh(offset.y / offset.x) - PI
	get_tree().current_scene.add_child(sword)
	

func _process(_delta):
	movement = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		) * speed;
	if movement.x != 0 and movement.y != 0:
		movement *= .71
	
	if Input.is_action_just_pressed("left_click") and sword == null:
		sword = Sword.instantiate()
		updateSword()

func _physics_process(delta):
	velocity = lerp(velocity, movement, acceleration * delta)
	move_and_slide()
	
	if sword != null:
		updateSword()
