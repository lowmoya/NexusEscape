extends Node2D
class_name Weapon



# ################################################## #
# Enums                                              #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

enum WeaponType {Fist = 0, Sword, Gun, Flame, Count}



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var energy_cost = 1.0

var idle = true



# ################################################## #
# Utility Functions                                  #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack(_bonus_velocity = Vector2.ZERO):
	pass

func can_attack():
	return true

func tick(_delta):
	pass
