extends CharacterBody2D
class_name Entity


# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var max_health = 5
var health = null
@export var invincibility_millis = 20
var invincible_frame = 0
var defeated = false



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	health = max_health



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
	if current_time < invincible_frame:
		return
	invincible_frame = current_time + invincibility_millis
	
	# Update health and check if defeated
	health -= amount
	if health <= 0:
		defeated = true
		despawn()
