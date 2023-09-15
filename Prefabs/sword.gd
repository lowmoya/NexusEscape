extends Weapon

var blade = null
var slash = null

var angle = -PI / 2
@export var speed = 4 * PI
@export var knockback = 2000

func _ready():
	blade = get_node("HitArea")
	slash = get_node("Swordslash")


func attack():
	idle = false
	slash.visible = true


func _on_hit_box_body_entered(body):
	if not (body is Entity) or idle:
		return
	elif is_in_group("Good"):
		if body.is_in_group("Good"):
			return
	elif is_in_group("Bad"):
		if body.is_in_group("Bad"):
			return
	
	body.damage(2)
	body.velocity += (body.get_global_position() - get_global_position()).normalized() * knockback


func tick(delta):
	if idle:
		return
	
	angle += speed * delta
	if angle >= PI / 2:
		angle = -PI /2
		idle = true
		slash.visible = false
	blade.rotation = angle
