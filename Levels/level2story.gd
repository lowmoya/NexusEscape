extends Control

@export var n_corrupt: Control
@export var n_story: Control

var delay = 2.

func _process(delta):
	if delay > 0:
		delay -= delta
		if delay <= 0:
			n_corrupt.visible = false
			n_story.process_mode = Node.PROCESS_MODE_ALWAYS
			n_story.visible = true
			n_story.add_message()


func done():
	get_tree().change_scene_to_file("res://Levels/level2.tscn")
