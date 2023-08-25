extends Weapon

var blade = null
var slash = null

var angle = -PI / 2
@export var speed = 4 * PI

func _ready():
	blade = get_node("HitArea")
	slash = get_node("Swordslash")

func attack():
	idle = false
	slash.visible = true
	



func _physics_process(delta):
	if idle:
		return
	
	angle += speed * delta
	if angle >= PI / 2:
		angle = -PI /2
		idle = true
		slash.visible = false
	blade.rotation = angle
