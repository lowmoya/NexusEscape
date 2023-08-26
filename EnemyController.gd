extends Node

@export var seperation_threshold = 200
@export var seperation_force = 400

var enemies = []

func _ready():
	enemies.append(get_node("Enemy"))
	enemies.append(get_node("Enemy2"))
	enemies.append(get_node("Enemy3"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var enemy_count = len(enemies)
	for i in range(enemy_count):
		for j in range(i + 1, enemy_count):
			var offset = enemies[j].global_position - enemies[i].global_position
			var distance = sqrt(offset.x * offset.x + offset.y * offset.y)
			
			if distance >= seperation_threshold:
				continue
			var push = (offset / distance) * seperation_force * delta
			enemies[i].velocity -= push
			enemies[j].velocity += push
