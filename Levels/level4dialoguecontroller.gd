extends Node2D

@export var n_dialogue: Control


func dialogue_heard():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	n_dialogue.call_deferred("say", "Did I do it? Did I make it out?\nNo. There's still [b]something[/b] up ahead.\nWhat is that thing?")

