extends CanvasLayer

var health_bar = null
var energy_bar = null
var player = null

func _ready():
	health_bar = get_node("HealthBar")
	energy_bar = get_node("EnergyBar")
	player = get_tree().current_scene.get_node("Player")
	health_bar.max_value = player.health
	energy_bar.max_value = player.energy


func _process(delta):
	if player != null:
		health_bar.value = player.health
		energy_bar.value = player.energy
	else:
		health_bar.value = 0
		energy_bar.value = 0
