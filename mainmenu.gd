extends Control

@export var n_splashscreen: TextureRect
var shader

const max_star_count = 30
var star_count = 0
var max_star_delay = 1.4
var star_delay = randf() * max_star_delay
var stars = []

func _ready():
	shader = n_splashscreen.material as ShaderMaterial

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

func _topdown_button():
	get_tree().change_scene_to_file("res://Levels/level1story.tscn")


func _on_topdown_button_button_down():
	pass # Replace with function body.
