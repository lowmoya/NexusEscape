extends CanvasLayer



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

var n_health_bar = null
var n_energy_bar = null
var n_dash_fill = null
var n_weapon_fills = [ ]
var n_player = null

var last_weapon = null



# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_health_bar = get_node("HealthBar")
	n_energy_bar = get_node("EnergyBar")
	n_dash_fill = get_node("Itembar/DashBackground")
	n_weapon_fills.resize(Weapon.WeaponType.Count)
	n_weapon_fills[Weapon.WeaponType.Fist] = [ get_node("Itembar/Fist/SelectedFill"), \
			get_node("Itembar/Fist/UnselectedFill") ]
	n_weapon_fills[Weapon.WeaponType.Sword] = [ get_node("Itembar/Sword/SelectedFill"), \
			get_node("Itembar/Sword/UnselectedFill") ]
	n_weapon_fills[Weapon.WeaponType.Gun] = [ get_node("Itembar/Gun/SelectedFill"), \
			get_node("Itembar/Gun/UnselectedFill") ]
	n_player = get_tree().current_scene.get_node("Player")
	last_weapon = n_player.weapon
	
	# Set bar max values
	n_health_bar.max_value = n_player.max_health
	n_energy_bar.max_value = n_player.max_energy


func _process(delta):
	# If there's not a player set health and energy to zero and return
	if n_player == null:
		n_health_bar.value = 0
		n_energy_bar.value = 0
		return
	
	# Set status bars
	n_health_bar.value = n_player.health
	n_energy_bar.value = n_player.energy
	
	# Set dash icon
	var dash_difference = n_player.dash_frame - Time.get_ticks_msec()
	if dash_difference > 0:
		var relation = float(dash_difference) / n_player.dash_delay
		n_dash_fill.scale.y = 1 - relation
		n_dash_fill.position.y = 4.5 * relation - .5
	elif n_dash_fill.scale.y != 1.:
		n_dash_fill.scale.y = 1.
		n_dash_fill.position.y = -.5
	
	# Set selected weapon if it's changed
	if last_weapon != n_player.weapon:
		n_weapon_fills[last_weapon][0].visible = false
		n_weapon_fills[last_weapon][1].visible = true
		last_weapon = n_player.weapon
		n_weapon_fills[last_weapon][0].visible = true
		n_weapon_fills[last_weapon][1].visible = false
