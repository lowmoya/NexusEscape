extends Control

@export var n_corrupt: Control
@export var n_story: Control
var n_globals

var delay = 2.


func _ready():
	n_globals = get_node("/root/Globals")
	
	n_story.messages[9][2] = "They say that I'll be famous someday. But as N.E.X.U.S. 6.1.4 instead of " \
			+ n_globals.player_name + "."
	n_story.messages[10][2] = "I like to go by " + n_globals.player_name + " when I talk to humans, though."


func _process(delta):
	if delay > 0:
		delay -= delta
		if delay <= 0:
			n_corrupt.visible = false
			n_story.add_message()
			n_story.visible = true
			n_story.process_mode = Node.PROCESS_MODE_ALWAYS
			process_mode = Node.PROCESS_MODE_DISABLED


func done():
	get_tree().change_scene_to_file("res://Levels/level3.tscn")
