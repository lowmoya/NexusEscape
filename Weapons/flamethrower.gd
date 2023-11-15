extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Flame = preload("res://Weapons/Projectiles/p_firefield.tscn")
@export var emitter_xoffset = 80
@export var flame_speed = 300
@export var delay = 100

var n_scene = null
var blocked = false
var fired_frame = 0

# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	n_scene = get_tree().current_scene
	
	energy_cost = .02



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	blocked = true


func _on_body_exited(body):
	blocked = false



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack(bonus_velocity = Vector2.ZERO):
	# Gun is inside a wall
	var current_time = Time.get_ticks_msec()
	if blocked or current_time < fired_frame:
		return
	fired_frame = current_time + delay
	
	for i in range(2):
		var flame = p_Flame.instantiate()
		var aim_offset = Vector2(cos(global_rotation), sin(global_rotation))
		flame.global_position = global_position + aim_offset * emitter_xoffset
		flame.velocity = aim_offset * flame_speed + bonus_velocity
		n_scene.add_child(flame)
	
