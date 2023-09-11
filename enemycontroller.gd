# Swarm behaviors / collisions

extends Node

@export var seperation_threshold = 200
@export var seperation_force = 400

var enemies = []


func _ready():
	for i in range (get_child_count()):
		enemies.append(get_child(i))


func _process(delta):
	var enemy_count = len(enemies)
	var enemy = 0
	while enemy < enemy_count:
		if not enemies[enemy].defeated:
			enemy += 1
			continue
		enemies[enemy].queue_free()
		enemy_count -= 1
		enemies[enemy] = enemies[enemy_count]
		enemies.pop_back()
	
	for i in range(enemy_count):
		for j in range(i + 1, enemy_count):
			var offset = enemies[j].global_position - enemies[i].global_position
			var distance = sqrt(offset.x * offset.x + offset.y * offset.y)
			
			if distance >= seperation_threshold:
				continue
			var push = (offset / distance) * seperation_force * delta
			enemies[i].velocity -= push
			enemies[j].velocity += push
