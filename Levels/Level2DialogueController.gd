extends Node2D


@export var n_dialogue: Control
@export var n_enemycontroller: Node2D
@export var n_player: CharacterBody2D
@export var n_playerui: CanvasLayer


func _ready():
	n_dialogue.call_deferred("say", "Well...\n\nI must be going in the right direction!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if n_enemycontroller.idle_enemy_count == 0 and n_enemycontroller.enemy_count == 0:
		n_dialogue.say("[b]Gun[/b] [i]added to database.[/i]\n\nThis doesn't feel like training. This is scary.\n\nThe rest of the world is... so far away.\n\nBut I can make it back there. I know I can. I'll see you soon, Mel!")
		process_mode = Node.PROCESS_MODE_DISABLED
		n_player.mastery = 2
		n_playerui.n_gun.visible = true

func dialogue_heard():
	pass
