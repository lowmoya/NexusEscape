extends CharacterBody2D

class_name Entity

var health = 5
var delete = false

func damage(amount):
	health -= amount
	if health <= 0:
		delete = true
