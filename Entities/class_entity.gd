extends CharacterBody2D
class_name Entity


# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var max_health = 5
@export var health: int
@export var invincibility_millis = 100
var invincibility_frame = 0
var defeated = false

var n_player: CharacterBody2D
var n_shader


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
