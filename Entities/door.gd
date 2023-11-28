extends StaticBody2D

enum DoorType {
	BRITTLE = 0,
	VINE,
	GLASS,
	ICE,
	METAL
}

@export var type: DoorType
@export var n_sprite: Sprite2D
var n_shader: ShaderMaterial

var health = 5
var damage_frame = 0
var immune_frame = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	n_sprite.frame_coords.y = type + 3
	n_shader = n_sprite.material as ShaderMaterial


func _physics_process(delta):
	if damage_frame > 0.:
		damage_frame -= delta
		n_shader.set_shader_parameter("damage_frame", damage_frame if damage_frame > 0 else 0)
	if immune_frame > 0.:
		immune_frame -= delta
		n_shader.set_shader_parameter("immune_frame", immune_frame if immune_frame > 0 else 0)


func try(key):
	if key == type:
		health -= 1
		if health == 0:
			queue_free()
		else:
			damage_frame = .1
	else:
		immune_frame = .3
