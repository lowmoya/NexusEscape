extends CharacterBody2D

class_name Entity

@export var health = 5
@export var invincibility_millis = 20
var last_hit = 0
var defeated = false

func damage(amount):
	if Time.get_ticks_msec() - last_hit < invincibility_millis:
		return
	last_hit = Time.get_ticks_msec()
	health -= amount
	if health <= 0:
		defeated = true
