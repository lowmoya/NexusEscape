extends CanvasLayer

var frame = 0.

@export var n_options: TextureRect
@export var n_controls: TextureRect
@export var n_click_audioplayer: AudioStreamPlayer
@export var n_hover_audioplayer: AudioStreamPlayer


@export var master_slider: HSlider
@export var music_slider: HSlider
@export var dialogue_slider: HSlider
@export var menu_slider: HSlider
@export var player_slider: HSlider
@export var enemy_slider: HSlider

var master_bus
var music_bus
var dialogue_bus
var menu_bus
var player_bus
var enemy_bus

func _ready():
	var previous
	master_bus = AudioServer.get_bus_index("Master")
	previous = AudioServer.get_bus_volume_db(master_bus)
	master_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0
	
	music_bus = AudioServer.get_bus_index("Music")
	previous = AudioServer.get_bus_volume_db(music_bus)
	music_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0
	
	dialogue_bus = AudioServer.get_bus_index("Dialogue")
	previous = AudioServer.get_bus_volume_db(dialogue_bus)
	dialogue_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0
	
	menu_bus = AudioServer.get_bus_index("Menu")
	previous = AudioServer.get_bus_volume_db(menu_bus)
	menu_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0
	
	player_bus = AudioServer.get_bus_index("Player")
	previous = AudioServer.get_bus_volume_db(player_bus)
	player_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0
	
	enemy_bus = AudioServer.get_bus_index("Enemy")
	previous = AudioServer.get_bus_volume_db(enemy_bus)
	enemy_slider.value = previous / 2 if previous > 0 else previous / 20 if previous < 0 else 0

func _on_exit_pressed():
	get_tree().quit()


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if n_options.visible:
			n_options.visible = false
			n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
			n_click_audioplayer.play()
		elif n_controls.visible:
			n_controls.visible = false
			n_click_audioplayer.pitch_scale = randf_range(1., 1.1)
			n_click_audioplayer.play()
		elif Time.get_ticks_msec() > frame:
			visible = false
			get_tree().paused = false
			process_mode = Node.PROCESS_MODE_DISABLED

func _on_resume_button_pressed():
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_DISABLED

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

