extends Area2D

@export var n_entrance: CollisionShape2D
@export var n_player_camera: Camera2D
@export var n_boss_camera: Camera2D
@export var n_musicplayer: AudioStreamPlayer

@export var n_bossstream = load("res://Resources/Music/boss_song.mp3")


func _on_body_entered(_body):
	n_boss_camera.enabled = true
	n_player_camera.enabled = false
	n_player_camera.enabled = true
	n_entrance.visible = true
	n_entrance.set_deferred("disabled", false)
	n_musicplayer.stream = n_bossstream
	n_musicplayer.play()
	queue_free()
