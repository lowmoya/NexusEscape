extends Node



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

# Drop prefab and variables
@export var p_Pickup = preload("res://Entities/pickup.tscn")
@export var p_Poof = preload("res://Entities/poof.tscn")
@export var drop_chance = .5

@export var enemy_seperation_threshold = 130000
@export var enemy_seperation_force = 40000
@export var enemy_alert_range = 260000

# Node references and random generator
var n_scene: Node
@export var n_player: Node2D

# Enemy list
var idle_enemies = []
var idle_enemy_count = 0
var enemies = []
var enemy_count = 0



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Get the references for required nodes
	n_scene = get_tree().current_scene
	
	# Add children to enemies list
	for i in range(get_child_count()):
		idle_enemies.append(get_child(i))
		idle_enemy_count += 1


func _process(delta):
	# Check if any enemies are close enough for activation or have been damaged
	var enemy = 0
	while enemy < idle_enemy_count:
		var player_offset = n_player.global_position - idle_enemies[enemy].global_position
		if idle_enemies[enemy].health != idle_enemies[enemy].max_health or \
				player_offset.x ** 2 + player_offset.y ** 2 <= enemy_alert_range:
			activate_enemy(enemy)
		else:
			enemy += 1

	# Iterate through the enemies processing any defeats and adjusting the list accordingly
	# Note: Only needs to check if defeated for active enemies as enemies will activate up on
	# damaged
	enemy = 0
	while enemy < enemy_count:
		# Skip healthy enemies
		if not enemies[enemy].defeated:
			enemy += 1
			continue
		
		var n_poof = p_Poof.instantiate()
		n_poof.global_position = enemies[enemy].global_position
		n_scene.add_child(n_poof)

		
		# Check if something should drop
		if randf() < drop_chance:
			# Create a pickup and initialize its values
			var n_pickup = p_Pickup.instantiate()
			n_pickup.type = randi_range(0, Pickup.PickupType.COUNT - 1)
			n_pickup.n_target = n_player
			n_pickup.global_position = enemies[enemy].global_position
			n_scene.add_child(n_pickup)
		
		# Delete the enemy and remove it from the list
		enemies[enemy].queue_free()
		enemy_count -= 1
		enemies[enemy] = enemies[enemy_count]
		enemies.pop_back()
	
	# Iterate through the enemies applying seperation forces and have activated enemies activate
	# any enemy within a distance
	var i = 0
	while i < enemy_count:
		# Activate any enemies in the proximity
		var j = 0
		while j < idle_enemy_count:
			var offset = idle_enemies[j].global_position - enemies[i].global_position
			if offset.x ** 2 + offset.y ** 2 > enemy_seperation_threshold:
				j += 1
				continue
			activate_enemy(j)
			
		# Apply a force to any enemies in the proximity
		j = i + 1
		while j < enemy_count:
			var offset = enemies[j].global_position - enemies[i].global_position
			var squared_distance: float = offset.x ** 2 + offset.y ** 2
			if squared_distance > enemy_seperation_threshold:
				j += 1
				continue
			var push = offset * (enemy_seperation_force * delta / squared_distance)
			enemies[i].velocity -= push
			enemies[j].velocity += push
			j += 1
		
		i += 1
		
	if idle_enemy_count == 0 and enemy_count == 0:
		n_player.energy = n_player.max_energy



# ################################################## #
# Utility Functions                                  #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func activate_enemy(enemy):
	# Toggle enemies idle condition (pass player data)
	idle_enemies[enemy].n_player = n_player
	idle_enemies[enemy].n_alert_audioplayer.pitch_scale = randf_range(.9, 1.1)
	idle_enemies[enemy].n_alert_audioplayer.play()
	# Move idle enemy to non-idle enemy list
	enemies.append(idle_enemies[enemy])
	enemy_count += 1
	idle_enemy_count -= 1
	idle_enemies[enemy] = idle_enemies[idle_enemy_count]
	idle_enemies.pop_back()
