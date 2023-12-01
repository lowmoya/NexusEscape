extends Control

@export var n_messagebox: VBoxContainer
@export var n_continue: TextureRect
@export var n_exit: TextureRect
@export var messages: Array
@export var n_host: Control
@export var n_click_audioplayer: AudioStreamPlayer
@export var n_typing_audioplayer: AudioStreamPlayer
var n_globals
var message_length: int
var message_index: int

var long_typing_samples = [
	load("res://Resources/Sound Effects/other sounds/friend_typing_1.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_3.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_6.wav")
]
const long_typing_sample_count = 3
var medium_typing_samples = [  # < 2.
	load("res://Resources/Sound Effects/other sounds/friend_typing_2.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_4.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_7.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_9.wav"),
]
const medium_typing_sample_count = 4
var short_typing_samples = [ # < 1.
	load("res://Resources/Sound Effects/other sounds/friend_typing_5.wav"),
	load("res://Resources/Sound Effects/other sounds/friend_typing_8.wav"),
	
]
const short_typing_sample_count = 2

var player_samples = [
	load("res://Resources/Sound Effects/player character sounds/voice_1.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_2.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_3.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_4.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_5.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_6.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_7.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_8.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_9.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_10.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_11.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_12.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_13.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_14.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_15.wav"),
	load("res://Resources/Sound Effects/player character sounds/voice_16.wav")
]
const player_sample_count = 16

var p_SmallAiMessage = preload("res://UI/ai_small_chat.tscn")
var p_MediumAiMessage = preload("res://UI/ai_medium_chat.tscn")
var p_BigAiMessage = preload("res://UI/ai_big_chat.tscn")
var p_SmallAnonMessage = preload("res://UI/anon_small_chat.tscn")
var p_MediumAnonMessage = preload("res://UI/anon_medium_chat.tscn")
var p_BigAnonMessage = preload("res://UI/anon_big_chat.tscn")
var p_Date = preload("res://UI/date_chat.tscn")

enum SizeLabel { SMALL, MEDIUM, BIG}

var phase = 0

func _ready():
	n_globals = get_node("/root/Globals")
	message_index = 0
	message_length = messages.size()

func add_message():
	var message = messages[message_index]
	message_index += 1
	var n_message
	if message[0] == "!P":
		match message[1]:
			SizeLabel.SMALL:
				n_message = p_SmallAiMessage.instantiate()
			SizeLabel.MEDIUM:
				n_message = p_MediumAiMessage.instantiate()
			_: # BIG
				n_message = p_BigAiMessage.instantiate()
		# check singleton for the players name, default value should be You
		n_message.n_name.text = "[b]" + n_globals.player_name
		n_typing_audioplayer.stream = player_samples[randi_range(0, player_sample_count - 1)]
		n_typing_audioplayer.play()
	elif message[0] == "!D":
		if message_index != message_length:
			n_message = p_Date.instantiate()
			n_message.n_message.text = message[2]
			n_messagebox.add_child(n_message)
			if message_index == message_length:
				if phase == 0:
					n_continue.visible = false
					n_exit.visible = true
			else:
				add_message()
			return
		else:
			n_host.done()
			return
	else:
		match message[1]:
			SizeLabel.SMALL:
				n_message = p_SmallAnonMessage.instantiate()
				n_typing_audioplayer.stream = short_typing_samples[randi_range(0, \
						short_typing_sample_count - 1)]
				n_typing_audioplayer.play()
			SizeLabel.MEDIUM:
				n_message = p_MediumAnonMessage.instantiate()
				n_typing_audioplayer.stream = medium_typing_samples[randi_range(0, \
						medium_typing_sample_count - 1)]
			_:
				n_message = p_BigAnonMessage.instantiate()
				n_typing_audioplayer.stream = long_typing_samples[randi_range(0, \
						long_typing_sample_count - 1)]
		n_message.n_name.text = message[0]
	n_message.n_message.text = message[2]
	n_messagebox.add_child(n_message)


func _process(_delta):
	if Input.is_action_just_pressed("continue"):
		n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
		n_click_audioplayer.play()
		print(message_index, ' ', message_length)
		if message_index == message_length:
			n_host.done()
			return
		elif phase == 0 and message_index == message_length - 1:
			n_continue.visible = false
			n_exit.visible = true
		add_message()
	elif Input.is_action_just_pressed("pause"):
		n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
		n_click_audioplayer.play()
		if message_index == message_length:
			n_host.done()
			return
		while message_index != message_length:
			add_message()
		n_typing_audioplayer.stop()
		if phase == 0:
			n_continue.visible = false
			n_exit.visible = true
