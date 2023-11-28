extends CharacterBody2D
class_name Entity


# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var max_health = 5
@export var health: float
@export var invincibility_millis = 100
var invincibility_frame = 0
var defeated = false

@export var n_alert_audioplayer: AudioStreamPlayer2D
@export var n_hurt_audioplayer: AudioStreamPlayer2D
@export var n_player: CharacterBody2D
var n_shader
var n_hurt_streams = [ load("res://Resources/Sound Effects/enemy sounds/enemy_damage_taken_1.wav"), \
		load("res://Resources/Sound Effects/enemy sounds/enemy_damage_taken_2.wav")]


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	health = max_health
	n_shader = ShaderMaterial.new()
	n_shader.shader = (material as ShaderMaterial).shader.duplicate()
	material = n_shader



# ################################################## #
# Utility Functions                                  #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func despawn():
	# By default it does nothing but can be overloaded in children to have special
	# on defeat effects
	pass

func damage(amount):
	# Invincibility frame implementation
	var current_time = Time.get_ticks_msec()
	if current_time < invincibility_frame:
		return
	invincibility_frame = current_time + invincibility_millis
	
	# Update health and check if defeated
	health -= amount
	if health <= 0:
		defeated = true
		despawn()
	else:
		n_hurt_audioplayer.stream = n_hurt_streams[randi_range(0, 1)]
		n_hurt_audioplayer.pitch_scale = randf_range(.9, 1.1)
		n_hurt_audioplayer.play()
