extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var p_Bullet = preload("res://Weapons/Projectiles/bullet.tscn")
@export var bullet_speed = 1000
@export var gun_emmiter_xoffset = 36

var n_scene = null
var blocked = false



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	n_scene = get_tree().current_scene



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
	
	# Create bullet and set its location and velocity
	var n_bullet = p_Bullet.instantiate()
	n_bullet.global_position = global_position + Vector2(cos(global_rotation), \
			sin(global_rotation)) * gun_emmiter_xoffset
	n_bullet.velocity = Vector2(cos(global_rotation), sin(global_rotation)) \
			* bullet_speed
	n_scene.add_child(n_bullet)
