extends Control


@export var n_hover_audioplayer: AudioStreamPlayer
@export var n_click_audioplayer: AudioStreamPlayer
@export var n_dialogue_audioplayer: AudioStreamPlayer
@export var n_popup: TextureRect
@export var n_label: RichTextLabel
@export var n_host: Node2D

var samples = [
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
const sample_count = 16

func say(message):
	n_label.text = message
	visible = true
	n_dialogue_audioplayer.stream = samples[randi_range(0, sample_count - 1)]
	n_dialogue_audioplayer.pitch_scale = randf_range(.9, 1.1)
	n_dialogue_audioplayer.play()


func _on_texture_button_pressed():
	n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
	n_click_audioplayer.play()
	visible = false
	n_host.dialogue_heard()


func _on_texture_button_mouse_entered():
	n_hover_audioplayer.pitch_scale = randf_range(.9, 1.1)
	n_hover_audioplayer.play()
