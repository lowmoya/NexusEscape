extends Entity



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var acceleration = 10
@export var speed = 100
@export var attack_delay = .5

var n_held = null
var n_weapon = null
var n_player = null

var current_attack_delay = 0 



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_held = get_node("Held")
	n_weapon = n_held.get_node("Gun")
	n_player = get_tree().current_scene.get_node("Player")
	
	# Initialize state
	health = max_health
	current_attack_delay = attack_delay


func _physics_process(delta):
	# Adjust velocity and move
	var move = Vector2(n_player.velocity + n_player.global_position - global_position).normalized()
	velocity = lerp(velocity, move * speed, acceleration * delta)
	move_and_slide()
	
	# Adjust held angle for simple predictive aiming
	var aim_offset = n_player.global_position - global_position
	n_held.rotation = atan(aim_offset.y / aim_offset.x)
	n_held.scale.x = -1 if aim_offset.x < 0 else 1
	
	# Decrement delay, when it hits zero attack and reset it
	current_attack_delay -= delta
	if current_attack_delay <= 0:
		n_weapon.attack()
		current_attack_delay = attack_delay
