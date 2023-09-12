extends CanvasLayer

var health_bar = null
var player = null

func _ready():
	health_bar = get_node("HBoxContainer/Health/Fill")
	player = get_tree().current_scene.get_node("Player")
	health_bar.max_value = player.health


func _process(delta):
	health_bar.value = player.health if player != null else 0
