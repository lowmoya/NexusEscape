extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var damage = 2
@export var speed = 4 * PI
@export var knockback = 2000

var n_blade = null
var n_slash = null
var n_audioplayer = null

var random_generator = RandomNumberGenerator.new()
var samples = []

var angle = -PI / 2



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load referenced nodes
	n_blade = get_node("HitArea")
	n_slash = get_node("Swordslash")
	
	# Prepare audio player
	n_audioplayer = get_node("AudioPlayer")
	samples.resize(2)
	samples[0] = load("res://Resources/Sound Effects/player weapons/sword_slice_1.wav")
	samples[1] = load("res://Resources/Sound Effects/player weapons/sword_slice_2.wav")



# ################################################## #
# Linked Functions                                   #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _on_hit_box_body_entered(body):
	# Handle cases where the collision event should be discarded
	if not (body is Entity) or idle or (is_in_group("Good") and body.is_in_group("Good")) \
			or (is_in_group("Bad") and body.is_in_group("Bad")):
		return
	
	# Damage and apply knockback
	body.damage(damage)
	body.velocity += (body.get_global_position() - get_global_position()).normalized() * knockback



# ################################################## #
# Class Functions                                    #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func attack():
	# Toggle slash effect and idle state
	if !idle:
		return
	idle = false
	n_slash.visible = true
	
	# Play sound
	n_audioplayer.stream = samples[random_generator.randi_range(0,1)]
	n_audioplayer.play()

func tick(delta):
	# Can skip if not currently attacking
	if idle:
		return
	
	# Adjust blades angle, resetting back to an idle state if it passes the threshold
	angle += speed * delta
	if angle >= PI / 2:
		n_slash.visible = false
		angle = -PI / 2
		idle = true
	n_blade.rotation = angle
