extends CharacterBody2D

class_name Entity

@export var max_health = 5
var health = null
@export var invincibility_millis = 20
var last_hit = 0
var defeated = false


func _ready():
	health = max_health


func despawn():
	pass


func damage(amount):
	if Time.get_ticks_msec() - last_hit < invincibility_millis:
		return
	last_hit = Time.get_ticks_msec()
	health -= amount
	if health <= 0:
		defeated = true
		despawn()
