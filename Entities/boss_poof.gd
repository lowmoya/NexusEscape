extends Sprite2D

@export var n_audio_player: AudioStreamPlayer

var n_boss_camera: Camera2D
var n_player_camera: Camera2D

const MAX_LIFE = .8
const FRAME_RATE = 5. / MAX_LIFE
var life = MAX_LIFE

func _ready():
	n_audio_player.pitch_scale = randf_range(.8,1.2)
	n_audio_player.play()

func _process(delta):
	frame = floor(FRAME_RATE * (MAX_LIFE - life))
	life -= delta
	if life < 0:
		n_boss_camera.enabled = false
		queue_free()
