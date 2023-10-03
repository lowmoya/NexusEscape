extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Flame = preload("res://Weapons/Projectiles/flame.tscn")
@export var emitter_xoffset = 50
@export var flame_speed = 4

var n_scene = null
var blocked = false


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	n_scene = get_tree().current_scene
	
	energy_cost = .1



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if body is TileMap:
		blocked = true


func _on_body_exited(body):
	if body is TileMap:
		blocked = false



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack():
	# Gun is inside a wall
	if blocked:
		return
	
	for i in range(15):
		var flame = p_Flame.instantiate()
		var aim_offset = Vector2(cos(global_rotation), sin(global_rotation))
		flame.global_position = global_position + aim_offset * emitter_xoffset
		flame.velocity = aim_offset * flame_speed
		n_scene.add_child(flame)
	
