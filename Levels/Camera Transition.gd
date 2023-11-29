extends Area2D

@export var n_entrance: CollisionShape2D
@export var n_player_camera: Camera2D
@export var n_boss_camera: Camera2D



func _on_body_entered(_body):
	n_boss_camera.enabled = true
	n_player_camera.enabled = false
	n_entrance.visible = true
	n_entrance.set_deferred("disabled", false)
