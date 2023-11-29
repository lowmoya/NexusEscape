extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

var p_Pickup = preload("res://Entities/pickup.tscn")

@export var n_player: CharacterBody2D
var n_scene

# Audio
var n_audioplayer = null
var audiosamples = []
const audiosample_count = 3
var random_generator = RandomNumberGenerator.new()

# State
@export var reach = 60
@export var speed = 500
@export var knockback = 800
var start_offset = null
var end_offset = null
var direction = 0
var obstructed = false



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Initialize state
	start_offset = position.x
	end_offset = position.x + reach
	
	# Prepare audio player
	n_audioplayer = get_node("AudioPlayer")
	audiosamples.resize(3)
	audiosamples[0] = load("res://Resources/Sound Effects/player weapons/punch_1.wav")
	audiosamples[1] = load("res://Resources/Sound Effects/player weapons/punch_2.wav")
	audiosamples[2] = load("res://Resources/Sound Effects/player weapons/punch_3.wav")
	
	n_scene = get_tree().current_scene



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if direction == 0:
		return
	elif body is Entity:
		body.damage(3)
		body.velocity += (body.global_position - global_position).normalized() * knockback
		if randi_range(1, 8) == 1:
			var pickup = p_Pickup.instantiate()
			pickup.type = Pickup.PickupType.ENERGY
			pickup.global_position = global_position
			pickup.n_target = n_player
			n_scene.add_child(pickup)
	elif not body is TileMap:
		body.try(0)
	direction = 0



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack(_bonus_velocity = Vector2.ZERO):
	if not idle or obstructed:
		return
	idle = false
	n_audioplayer.pitch_scale = randf_range(.9, 1.1)
	n_audioplayer.stream = audiosamples[random_generator.randi_range(0, 2)]
	n_audioplayer.play()
	direction = 1

func can_attack():
	return idle and not obstructed

func tick(delta):
	if idle:
		return
	
	if direction == 1:
		if position.x > end_offset:
			direction = 0
		else:
			position.x += speed * delta
	else:
		if position.x <= start_offset:
			position.x = start_offset
			idle = true
		else:
			position.x -= speed * delta
	



func _on_obstruction_area_body_entered(_body):
	obstructed = true


func _on_obstruction_area_body_exited(_body):
	obstructed = false
