extends Control

@export var n_splashscreen: TextureRect
@export var n_click_audioplayer: AudioStreamPlayer
@export var n_hover_audioplayer: AudioStreamPlayer
@export var n_options: TextureRect
@export var n_controls: TextureRect
var shader

const max_star_count = 30
var star_count = 0
var max_star_delay = 1.4
var star_delay = randf() * max_star_delay
var stars = []

var master_bus
var music_bus
var dialogue_bus
var menu_bus
var player_bus
var enemy_bus

func _ready():
	shader = n_splashscreen.material as ShaderMaterial
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	dialogue_bus = AudioServer.get_bus_index("Dialogue")
	menu_bus = AudioServer.get_bus_index("Menu")
	player_bus = AudioServer.get_bus_index("Player")
	enemy_bus = AudioServer.get_bus_index("Enemy")

func _physics_process(delta):
	var i = 0
	while i < star_count:
		stars[i].z -= delta
		if stars[i].z <= 0.:
			star_count -= 1
			stars[i] = stars[star_count]
			stars.pop_back()
		else:
			i += 1
	if star_count < max_star_count and star_delay <= 0:
		stars.append(Vector4(randf(), randf(), randf_range(1.2, 3), \
				randf_range(0.004, 0.01)))
		star_count += 1
		star_delay = randf() * max_star_delay
	else:
		star_delay -= delta
	shader.set_shader_parameter("count", star_count)
	shader.set_shader_parameter("points", stars)
	
	if Input.is_action_just_pressed("pause"):
		if n_options.visible == true:
			n_options.visible = false
			n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
			n_click_audioplayer.play()
		elif n_controls.visible == true:
			n_controls.visible = false
			n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
			n_click_audioplayer.play()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Levels/level1story.tscn")

func _on_options_button_pressed():
	n_options.visible = true


func _on_controls_button_pressed():
	n_controls.visible = true

func _on_quit_button_pressed():
	get_tree().quit()

func _on_controls_close_button_pressed():
	n_controls.visible = false


func _on_options_close_button_pressed():
	n_options.visible = false


func _on_button_mouse_entered():
	n_hover_audioplayer.pitch_scale = randf_range(.9, 1.1)
	n_hover_audioplayer.play()


func _on_button_down():
	n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
	n_click_audioplayer.play()



func _on_master_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
	AudioServer.set_bus_volume_db(master_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)


func _on_music_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)
	AudioServer.set_bus_volume_db(music_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)


func _on_dialogue_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(dialogue_bus, true)
	else:
		AudioServer.set_bus_mute(dialogue_bus, false)
	AudioServer.set_bus_volume_db(dialogue_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)

func _on_menu_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(menu_bus, true)
	else:
		AudioServer.set_bus_mute(menu_bus, false)
	AudioServer.set_bus_volume_db(menu_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)

func _on_player_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(player_bus, true)
	else:
		AudioServer.set_bus_mute(player_bus, false)
	AudioServer.set_bus_volume_db(player_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)


func _on_enemy_slider_value_changed(value):
	if value == -1:
		AudioServer.set_bus_mute(enemy_bus, true)
	else:
		AudioServer.set_bus_mute(enemy_bus, false)
	AudioServer.set_bus_volume_db(enemy_bus, 20 * value if value < 0. else \
			2 * value if value > 0. else 0.)


