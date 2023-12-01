extends Control

@export var n_corrupt: Control
@export var n_namebox: ColorRect
@export var n_nameentry: LineEdit
@export var n_story: Control
@export var n_audioplayer: AudioStreamPlayer
var n_globals


var delay = 2.

var phase = 1


func _ready():
	n_globals = get_node("/root/Globals")
	n_story.phase = 1


func _process(delta):
	if delay > 0:
		delay -= delta
		if delay <= 0:
			n_corrupt.visible = false
			n_story.process_mode = Node.PROCESS_MODE_ALWAYS
			n_story.visible = true
			n_story.add_message()
		
		
	if n_namebox.visible and Input.is_key_label_pressed(KEY_ENTER):
		submit_name()


func done():
	#first call prompt for player name then retool, second load next scene
	if phase == 1:
		n_namebox.visible = true
		n_story.process_mode = Node.PROCESS_MODE_DISABLED
		n_story.n_continue.visible = false
		phase = 0
	else:
		get_tree().change_scene_to_file("res://Levels/level1.tscn")


func submit_name():
	n_audioplayer.pitch_scale = randf_range(1., 1.1)
	n_audioplayer.play()
	
	n_namebox.visible = false
	n_globals.player_name = n_nameentry.text if n_nameentry.text.length() != 0 \
			else n_nameentry.placeholder_text
	n_story.messages = [
		["!P", 0, "I'm " + n_globals.player_name + "! Can we be friends?"],
		["[b]mel", 0, "sure! i just sent you a request!!"],
	]
	n_story.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	n_story._ready()
	n_story.phase = 0
	n_story.n_continue.visible = true
	n_story.add_message()
	

func _on_button_pressed():
	submit_name()


