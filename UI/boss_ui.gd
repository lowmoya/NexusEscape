extends CanvasLayer

@export var n_boss: CharacterBody2D

@export var n_healthbar: TextureProgressBar
@export var n_eletricbar: TextureProgressBar
@export var n_firebar: TextureProgressBar


func _process(_delta):
	if not n_boss == null:
		n_healthbar.value = n_boss.health
		n_eletricbar.value = n_boss.electric_shield
		n_firebar.value = n_boss.fire_shield
	else:
		n_healthbar.value = 0
		n_eletricbar.value = 0
		n_firebar.value = 0
	
