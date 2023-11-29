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

var fire_stacks: float = 0.
var fire_frame: float = 0.

# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	health = max_health
	n_shader = ShaderMaterial.new()
	n_shader.shader = (material as ShaderMaterial).shader.duplicate()
	material = n_shader


func update(delta, flame_resistant = false):
	var current_time = Time.get_ticks_msec()
	n_shader.set_shader_parameter("frame", invincibility_frame - current_time \
			if current_time <= invincibility_frame else 0)
	if flame_resistant:
		return
	if fire_stacks > 10.:
		fire_stacks = 10.
	n_shader.set_shader_parameter("firestacks", fire_stacks) 
	if fire_frame >= 1.:
		fire_frame -= 1.
		if fire_stacks > 0.:
			damage(fire_stacks)
			fire_stacks = fire_stacks - 1. if fire_stacks > 1. else 0.
	else:
		fire_frame += delta


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
