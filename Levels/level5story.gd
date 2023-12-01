extends Control

@export var n_corrupt: Control
@export var n_story: Control
var n_globals

var delay = 2.


func _ready():
	n_globals = get_node("/root/Globals")
	n_story.messages[18][2] = n_globals.player_name + "?"
	n_story.messages[20][2] = n_globals.player_name + "??"
	n_story.messages[22][2] = n_globals.player_name + " please reply"


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
	get_tree().change_scene_to_file("res://Levels/level5.tscn")
