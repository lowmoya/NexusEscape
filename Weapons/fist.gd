extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

# Audio
var n_audioplayer = null
var audiosamples = []
const audiosample_count = 3
var random_generator = RandomNumberGenerator.new()

# State
@export var reach = 60
@export var speed = 500
@export var knockback = 800
var start_offset = null
var end_offset = null
var direction = 1



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Initialize state
	start_offset = position.x
	end_offset = position.x + reach
	
	# Prepare audio player
	n_audioplayer = get_node("AudioPlayer")
	audiosamples.resize(3)
	audiosamples[0] = load("res://Resources/Sound Effects/player weapons/punch_1.wav")
	audiosamples[1] = load("res://Resources/Sound Effects/player weapons/punch_2.wav")
	audiosamples[2] = load("res://Resources/Sound Effects/player weapons/punch_3.wav")



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_body_entered(body):
	if direction == 0 or not (body is Entity) or (is_in_group("Good") and body.is_in_group("Good")) \
			or (is_in_group("Bad") and body.is_in_group("Bad")) :
		return
	body.damage(1)
	body.velocity += (body.global_position - global_position).normalized() * knockback
	direction = 0



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack(bonus_velocity = Vector2.ZERO):
	if not idle:
		return
	idle = false
	n_audioplayer.stream = audiosamples[random_generator.randi_range(0, 2)]
	n_audioplayer.play()

func tick(delta):
	if idle:
		return
	
	if direction == 1:
		if position.x > end_offset:
			direction = 0
		else:
			position.x += speed * delta
	else:
		if position.x <= start_offset:
			position.x = start_offset
			direction = 1
			idle = true
		else:
			position.x -= speed * delta
	

