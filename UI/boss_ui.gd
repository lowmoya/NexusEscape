extends CanvasLayer

@export var n_boss: CharacterBody2D

@export var n_control: Control

@export var n_back_swordbar: TextureProgressBar
@export var n_front_swordbar: TextureProgressBar
@export var n_back_gunbar: TextureProgressBar
@export var n_front_gunbar: TextureProgressBar
@export var n_back_coilbar: TextureProgressBar
@export var n_front_coilbar: TextureProgressBar

var n_shader: ShaderMaterial

const BAR_TRACK_RATE: float = 10.

var floating_coil: float
var floating_gun: float 
var floating_sword: float

func _ready():
	floating_sword = n_boss.sword_shield
	n_front_swordbar.value = n_boss.sword_shield
	floating_gun = n_boss.gun_shield
	n_front_gunbar.value = n_boss.gun_shield
	floating_coil = n_boss.health
	n_front_coilbar.value = n_boss.health
	
	n_shader = n_control.material as ShaderMaterial

func _process(delta):
	if not n_boss == null:
		if floating_coil != 0:
			if n_boss.health < 10.:
				n_shader.set_shader_parameter("shake", true)
			if floating_coil != n_boss.health:
				floating_coil += clamp(n_boss.health - floating_coil, -BAR_TRACK_RATE * delta, \
						BAR_TRACK_RATE * delta)
				n_back_coilbar.value = floating_coil
				n_front_coilbar.value = n_boss.health
				if floating_coil == 0:
					n_shader.set_shader_parameter("shake", false)
					n_front_gunbar.visible = false
					n_back_gunbar.visible = false
		if floating_gun != 0:
			if n_boss.gun_shield < 10.:
				n_shader.set_shader_parameter("shake", true)
			if floating_gun != n_boss.gun_shield:
				floating_gun += clamp(n_boss.gun_shield - floating_gun, -BAR_TRACK_RATE \
						* delta, BAR_TRACK_RATE * delta)
				n_back_gunbar.value = floating_gun
				n_front_gunbar.value = n_boss.gun_shield
				if floating_gun == 0:
					n_shader.set_shader_parameter("shake", false)
					n_back_gunbar.visible = false
					n_front_gunbar.visible = false
		if floating_sword != 0:
			if n_boss.sword_shield < 10.:
				n_shader.set_shader_parameter("shake", true)
			if floating_sword != n_boss.sword_shield:
				floating_sword += clamp(n_boss.sword_shield - floating_sword, -BAR_TRACK_RATE * delta, \
						BAR_TRACK_RATE * delta)
				#here check for zero and transition
				n_back_swordbar.value = floating_sword
				n_front_swordbar.value = n_boss.sword_shield
				if floating_sword == 0:
					n_shader.set_shader_parameter("shake", false)
					n_back_swordbar.visible = false
					n_front_swordbar.visible = false
	else:
		queue_free()
	
