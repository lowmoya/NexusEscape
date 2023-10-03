extends Weapon



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

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
	start_offset = position.x
	end_offset = position.x + reach



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

func attack():
	idle = false

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
	

