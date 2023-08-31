extends CharacterBody2D

class_name Entity

var health = 5
var defeated = false

func damage(amount):
	health -= amount
	if health <= 0:
		defeated = true
