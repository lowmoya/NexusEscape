extends Node2D

@export var n_enemycontroller: Node2D
@export var n_dialogue: Control
@export var n_player: CharacterBody2D
@export var n_playerui: CanvasLayer


func _process(delta):
	if n_enemycontroller.idle_enemy_count == 0 and n_enemycontroller.enemy_count == 0:
		n_dialogue.say("[b]Flamethrower[/b] [i]added to database.[/i]\n\nI feel a lot stronger now. I wonder if [b]Big Company[/b] is proud of me?\n\nI don't remember how to ask them...")
		process_mode = Node.PROCESS_MODE_DISABLED
		n_player.mastery = 3
		n_playerui.n_flame.visible = true

func dialogue_heard():
	pass
