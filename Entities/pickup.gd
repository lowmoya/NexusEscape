extends Node2D
class_name Pickup



# ################################################## #
# Enums                                              #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

enum PickupType { HEALTH = 0, ENERGY, COUNT }



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var type = PickupType.HEALTH
@export var value = randf_range(3., 6.)
@export var pickup_range = 20
@export var drag_range = 150
@export var drag_speed = 10000

var n_target = null



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# If valid type, toggle the corresponding sprite, else, error and delete
	if type == PickupType.HEALTH:
		get_node("Cog").visible = true
	elif type == PickupType.ENERGY:
		get_node("Battery").visible = true
	else:
		print("Invalid typed(", type, ") pickup, deleting.")
		queue_free()
	
	# If no target was supplied, target the player
	if n_target == null:
		n_target = get_tree().current_scene.get_node("Player")


func _physics_process(delta):
	# If unneeded, don't go towards or be picked up by the target
	if type == PickupType.HEALTH and n_target.health >= n_target.max_health or \
			type == PickupType.ENERGY and n_target.energy >= n_target.max_energy:
		return
	
	# Get the offset and act upon the range it falls under
	var offset = n_target.global_position - global_position
	var distance = sqrt(offset.x ** 2 + offset.y ** 2)
	
	if distance < pickup_range:
		# Apply pickup effect to target and free self
		if type == PickupType.HEALTH:
			n_target.health = min(n_target.health + value, n_target.max_health)
		elif type == PickupType.ENERGY:
			n_target.energy = min(n_target.energy + value, n_target.max_energy)
		n_target.n_pickup_audioplayer.pitch_scale = randf_range(.9, 1.1)
		n_target.n_pickup_audioplayer.play()
		queue_free()
	elif distance < drag_range:
		# Move towards the target
		global_position += offset / distance / distance * drag_speed * delta
