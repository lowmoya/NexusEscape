extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Bullet = preload("res://Weapons/Projectiles/p_bullet.tscn")
@export var bullet_speed = 1000
@export var gun_emmiter_xoffset = 50

var n_scene = null
var blocked = false

var n_audioplayer = null
var random_generator = RandomNumberGenerator.new()
var samples = [
	load("res://Resources/Sound Effects/player weapons/gun_shot_1.wav"),
	load("res://Resources/Sound Effects/player weapons/gun_shot_2.wav")
]
var sample_count = 1

const FIRE_COOLDOWN = 4e2
var last_fired = 0


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	n_scene = get_tree().current_scene
	
	# Prepare audio player
	n_audioplayer = get_node("AudioPlayer")
	random_generator.seed = Time.get_ticks_msec()



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(_body):
	blocked = true


func _on_body_exited(_body):
	blocked = false



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack(_bonus_velocity = Vector2.ZERO):
	# Gun is inside a wall
	var current_time = Time.get_ticks_msec()
	if blocked or current_time < last_fired:
		return
	last_fired = current_time + FIRE_COOLDOWN
	
	# Create bullet and set its location and velocity
	var n_bullet = p_Bullet.instantiate()
	n_bullet.global_position = global_position + Vector2(cos(global_rotation), \
			sin(global_rotation)) * gun_emmiter_xoffset
	n_bullet.velocity = Vector2(cos(global_rotation), sin(global_rotation)) \
			* bullet_speed
	n_scene.add_child(n_bullet)
	
	# Play sound
	n_audioplayer.pitch_scale = randf_range(.9, 1.1)
	n_audioplayer.stream = samples[random_generator.randi_range(0,sample_count)]
	n_audioplayer.play()

func can_attack():
	return not blocked and Time.get_ticks_msec() >= last_fired
