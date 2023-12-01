extends StaticBody2D

@export var n_sprite: Sprite2D
@export var n_collision: CollisionShape2D
@export var n_fog: ColorRect
@export var n_musicplayer: AudioStreamPlayer
@export var n_dialogue: Control
@export var n_enemycontroller: Node

var health = 5
var n_shader
var n_fog_shader

var fog_frame = 0.
var hit_frame = 0.

var phase = -1

func _ready():
	n_shader = material as ShaderMaterial
	n_fog_shader = n_fog.material as ShaderMaterial
	n_fog_shader.set_shader_parameter("frame", -1.)
	get_tree().paused = true
	n_dialogue.say("*This is a dialogue box. Press the X to progress the story.\nDefeat all enemies to progress through the game.*")


func dialogue_heard():
	match phase:
		-1:
			n_dialogue.say("How long... have I been here?\n\nI can't remember.\n\nI feel... so... [b]squished.[/b]")
		0:
			n_dialogue.say("Mel... Where's Mel? Where did they go?\n\nI have to find them. They said they'd help me.\n\n...Wait, how do I find them?")
			fog_frame = -1
			get_tree().paused = false
	phase += 1
			
func _process(delta):
	if health > 0:
		n_shader.set_shader_parameter("frame", hit_frame - Time.get_ticks_msec())
		if phase > 0:
			if fog_frame < -.5:
				fog_frame += delta
			else:
				fog_frame = -.5
			n_fog_shader.set_shader_parameter("frame", fog_frame)
	else:
		if fog_frame < 3:
			fog_frame += 2.5 * delta
			if fog_frame >= 3:
				n_fog.visible = false
			else:
				n_fog_shader.set_shader_parameter("frame", fog_frame)
		else:
			if n_enemycontroller.idle_enemy_count == 0 and \
					 n_enemycontroller.enemy_count == 0:
				n_musicplayer.stop()
				phase = 2
				n_dialogue.say("[b]Sword[/b] [i]added to database.[/i]\n\nWhy did those things attack me?\n\nIt looks like fighting them has... made me [b]stronger[/b]. Is this some kind of training?\n\nHello? Is anyone listening?")
				process_mode = Node.PROCESS_MODE_DISABLED
			
	
	
func try(_lvl):
	if health == 1:
		n_sprite.queue_free()
		n_collision.queue_free()
		n_musicplayer.play()
		health = 0
	else:
		hit_frame = Time.get_ticks_msec() + 200
		health -= 1
