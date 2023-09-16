extends CanvasLayer



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

var n_health_bar = null
var n_energy_bar = null
var n_player = null



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_health_bar = get_node("HealthBar")
	n_energy_bar = get_node("EnergyBar")
	n_player = get_tree().current_scene.get_node("Player")
	
	# Set bar max values
	n_health_bar.max_value = n_player.max_health
	n_energy_bar.max_value = n_player.max_energy


func _process(delta):
	# Set bar values if there's a player, else default to zero
	if n_player != null:
		n_health_bar.value = n_player.health
		n_energy_bar.value = n_player.energy
	else:
		n_health_bar.value = 0
		n_energy_bar.value = 0
