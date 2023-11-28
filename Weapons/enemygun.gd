extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Bullet = preload("res://Weapons/Projectiles/e_bullet.tscn")
@export var p_Frag = preload("res://Weapons/Projectiles/e_frag.tscn")
@export var bullet_speed = 500
@export var frag_speed = 500
@export var bullet_emmiter_xoffset = 60
@export var frag_emmiter_xoffset = 40
@export var frag_spread = PI / 12.

var n_scene = null
var blocked = false

var n_audioplayer = null
var random_generator = RandomNumberGenerator.new()
var samples = [
	load("res://Resources/Sound Effects/enemy sounds/gun_enemy_attack_fixed_1.wav"),
	load("res://Resources/Sound Effects/enemy sounds/gun_enemy_attack_fixed_2.wav"),
	load("res://Resources/Sound Effects/enemy sounds/gun_enemy_attack_fixed_3.wav")
]
var sample_count = 2


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

func attack(_bonus_velocity=Vector2.ZERO):
	# Gun is inside a wall
	if blocked:
		return
	
	# Create bullet and set its location and velocity
	var n_bullet = p_Bullet.instantiate()
	n_bullet.global_position = global_position + Vector2(cos(global_rotation), \
			sin(global_rotation)) * bullet_emmiter_xoffset
	n_bullet.velocity = Vector2(cos(global_rotation), sin(global_rotation)) \
			* bullet_speed
	n_scene.add_child(n_bullet)
	
	# Play sound
	n_audioplayer.pitch_scale = randf_range(1., 1.1)
	n_audioplayer.stream = samples[random_generator.randi_range(0,sample_count)]
	n_audioplayer.play()

func shotgun_attack(projectiles):
	# Gun is inside a wall
	if blocked:
		return
	
	# Create frag and set its location and velocity
	for i in range(projectiles):
		var n_frag = p_Frag.instantiate()
		n_frag.global_position = global_position + Vector2(cos(global_rotation), \
				sin(global_rotation)) * frag_emmiter_xoffset
		var inaccuracy_rotation = randf_range(-1, 1) * frag_spread
		n_frag.velocity = Vector2(cos(global_rotation), sin(global_rotation)).rotated( \
				inaccuracy_rotation) * frag_speed
		n_frag.rotation = inaccuracy_rotation + global_rotation
		n_scene.add_child(n_frag)
	
	# Play sound
	n_audioplayer.pitch_scale = randf_range(.9, 1.)
	n_audioplayer.stream = samples[random_generator.randi_range(0,sample_count)]
	n_audioplayer.play()
