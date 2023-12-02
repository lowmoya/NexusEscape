extends Node2D

@export var n_dialogue: Control
@export var n_enemycontroller: Node2D
@export var n_door: StaticBody2D

func dialogue_heard():
	pass

func _ready():
	n_dialogue.call_deferred("say", "Did I do it? Did I make it out?\n\nNo. There's still [b]something[/b] up ahead.\n\nWhat is that thing?")
	

func _process(_delta):
	if n_enemycontroller.enemy_count == 0 and n_enemycontroller.idle_enemy_count == 0:
		n_door.queue_free()
		process_mode = Node.PROCESS_MODE_DISABLED
