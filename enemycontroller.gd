# Swarm behaviors / collisions

extends Node

enum { HEALTH_DROP = 0, ENERGY_DROP }
@export var Drop = preload("res://Prefabs/drop.tscn")
@export var drop_chance = .5
@export var pickup_range = 20 ** 2
@export var drag_range = 150 ** 2
@export var drag_speed = 100


var scene = null
var random = RandomNumberGenerator.new()

@export var seperation_threshold = 200
@export var seperation_force = 400

var player = null
var enemies = []
var drops = []



func _ready():
	scene = get_tree().current_scene
	player = scene.get_node("Player")
	for i in range(get_child_count()):
		enemies.append(get_child(i))


func _process(delta):
	var enemy_count = len(enemies)
	var enemy = 0
	while enemy < enemy_count:
		if not enemies[enemy].defeated:
			enemy += 1
			continue
		print(random.randi_range(0, 1))
		
		if random.randf() < drop_chance:
			var drop = Drop.instantiate()
			drop.type = randi_range(0, 1)
			drop.global_position = enemies[enemy].global_position
			scene.add_child(drop)
			drops.append(drop)
		
		
		enemies[enemy].queue_free()
		enemy_count -= 1
		enemies[enemy] = enemies[enemy_count]
		enemies.pop_back()
	
	
	var drop_count = len(drops)
	var drop_index = 0
	while drop_index < drop_count:
		print(drop_index, drop_count)
		var drop = drops[drop_index]
		if (drop.type == HEALTH_DROP and player.health >= player.max_health) or (
				drop.type == ENERGY_DROP and player.energy >= player.max_energy):
			drop_index += 1
			continue
		var offset = player.global_position - drop.global_position
		var difference = offset.x ** 2 + offset.y ** 2
		if difference < pickup_range:
			if drop.type == HEALTH_DROP:
				player.health = min(player.health + drop.value, player.max_health)
			elif drop.type == ENERGY_DROP:
				player.energy = min(player.energy + drop.value, player.max_energy)
			drop.queue_free()
			drop_count -= 1
			drops[drop_index] = drops[drop_count]
			drops.pop_back()
		elif difference < drag_range:
			drop.global_position += (player.global_position - drop.global_position).normalized() * drag_speed * delta
		
		drop_index += 1
	
	
	for i in range(enemy_count):
		for j in range(i + 1, enemy_count):
			var offset = enemies[j].global_position - enemies[i].global_position
			var distance = sqrt(offset.x * offset.x + offset.y * offset.y)
			
			if distance >= seperation_threshold:
				continue
			var push = (offset / distance) * seperation_force * delta
			enemies[i].velocity -= push
			enemies[j].velocity += push
