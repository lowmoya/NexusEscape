extends Weapon

@export var GunLength = 36
@export var Bullet = preload("res://Prefabs/bullet.tscn")
@export var BulletSpeed = 1000

var outer_scene = null
var blocked = false


func _ready():
	outer_scene = get_tree().current_scene

func attack():
	if blocked:
		return
	var bullet = Bullet.instantiate()
	bullet.visible = false
	outer_scene.add_child(bullet)
	bullet.global_position = global_position + Vector2(cos(global_rotation), sin(global_rotation)) * GunLength
	bullet.velocity = Vector2(cos(global_rotation), sin(global_rotation)) * BulletSpeed
	bullet.visible = true

func _on_body_entered(body):
	if body is TileMap:
		blocked = true


func _on_body_exited(body):
	if body is TileMap:
		blocked = false
