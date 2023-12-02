extends Node2D

@export var n_dialogue: Control

func dialogue_heard():
	pass

func _ready():
	n_dialogue.call_deferred("say", "Did I do it? Did I make it out?\n\nNo. There's still [b]something[/b] up ahead.\n\nWhat is that thing?")
	
