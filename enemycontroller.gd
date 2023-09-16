extends Node



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

# Drop prefab and variables
@export var p_Pickup = preload("res://Entities/pickup.tscn")
@export var drop_chance = .5

@export var enemy_seperation_threshold = 200
@export var enemy_seperation_force = 400

# Node references and random generator
var n_scene = null
var n_player = null
var random = RandomNumberGenerator.new()

# Enemy list
var enemies = []



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Get the references for required nodes
	n_scene = get_tree().current_scene
	n_player = n_scene.get_node("Player")
	
	# Add children to enemies list
	for i in range(get_child_count()):
		enemies.append(get_child(i))


func _process(delta):
	# Iterate through the enemies processing any defeats and adjusting the list accordingly
	var enemy_count = len(enemies)
	var enemy = 0
	while enemy < enemy_count:
		# Skip healthy enemies
		if not enemies[enemy].defeated:
			enemy += 1
			continue
		
		# Check if something should drop
		if random.randf() < drop_chance:
			# Create a pickup and initialize its values
			var n_pickup = p_Pickup.instantiate()
			n_pickup.type = randi_range(0, Pickup.PickupType.COUNT)
			n_pickup.n_target = n_player
			n_pickup.global_position = enemies[enemy].global_position
			n_scene.add_child(n_pickup)
		
		# Delete the enemy and remove it from the list
		enemies[enemy].queue_free()
		enemy_count -= 1
		enemies[enemy] = enemies[enemy_count]
		enemies.pop_back()
	
	# Iterate through the enemies applying seperation forces
	for i in range(enemy_count):
		for j in range(i + 1, enemy_count):
			# Find offset and distance for calculating strength and direction of force
			var offset = enemies[j].global_position - enemies[i].global_position
			var distance = sqrt(offset.x ** 2 + offset.y ** 2)
			
			# Skip if distance is too great
			if distance >= enemy_seperation_threshold:
				continue
			
			# Apply the force to both enemies in the direction opposite to the
			# other enemy
			var push = (offset / distance) * enemy_seperation_force * delta
			enemies[i].velocity -= push
			enemies[j].velocity += push
