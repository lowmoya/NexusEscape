extends Area2D

@export var scene_path: String



func _on_body_entered(_body):
	get_tree().change_scene_to_file(scene_path)
