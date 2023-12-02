extends CanvasLayer



# ################################################## #
# Variables                                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

@export var n_front_health_bar: TextureProgressBar
@export var n_back_health_bar: TextureProgressBar
@export var n_front_energy_bar: TextureProgressBar
@export var n_back_energy_bar: TextureProgressBar
@export var n_dash_fill: Sprite2D
@export var n_itembar: Sprite2D
@export var n_player: CharacterBody2D

@export var n_sword: Sprite2D
@export var n_gun: Sprite2D
@export var n_flame: Sprite2D

var n_weapon_fills = [ ]
var last_weapon = null

const DAMAGE_COLOR = Color(1., .23, .14, 1.)
const HEAL_COLOR = Color(.34, .77, .94, 1.)
const DRAIN_COLOR = Color(.42, .42, .45, 1.)
const REPLENISH_COLOR = Color(.92, .92, 1., 1.)
const STATUS_MATCH_RATE = 2.3
var floating_health: float
var floating_energy: float


# ################################################## #
# Ready / Process Functions                          #
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv #

func _ready():
	# Load node references
	n_weapon_fills.resize(Weapon.WeaponType.Count)
	n_weapon_fills[Weapon.WeaponType.Fist] = [ n_itembar.get_node("Fist/SelectedFill"), \
			n_itembar.get_node("Fist/UnselectedFill") ]
	n_weapon_fills[Weapon.WeaponType.Sword] = [ n_itembar.get_node("Sword/SelectedFill"), \
			n_itembar.get_node("Sword/UnselectedFill") ]
	n_weapon_fills[Weapon.WeaponType.Gun] = [ n_itembar.get_node("Gun/SelectedFill"), \
			n_itembar.get_node("Gun/UnselectedFill") ]
	n_weapon_fills[Weapon.WeaponType.Flame] = [ n_itembar.get_node("Flame/SelectedFill"), \
			n_itembar.get_node("Flame/UnselectedFill") ]
	last_weapon = n_player.weapon
	
	match n_player.mastery:
		3:
			n_sword.visible = true
			n_gun.visible = true
			n_flame.visible = true
		2:
			n_sword.visible = true
			n_gun.visible = true
		1:
			n_sword.visible = true
			
	
	# Set bar max values
	n_front_health_bar.max_value = n_player.max_health
	n_back_health_bar.max_value = n_player.max_health
	floating_health = n_player.max_health
	n_front_energy_bar.max_value = n_player.max_energy
	n_back_energy_bar.max_value = n_player.max_energy
	floating_energy = n_player.max_energy


func _process(delta):
	
	# If there's not a player set health and energy to zero and return
	if n_player == null:
		n_front_health_bar.value = 0.
		n_back_health_bar.value = 0.
		n_front_energy_bar.value = 0.
		n_back_energy_bar.value = 0.
		return
	
	# Set status bars
	if floating_health < n_player.health:
		floating_health += clamp(n_player.health - floating_health, -STATUS_MATCH_RATE * delta, \
				STATUS_MATCH_RATE * delta)
		n_front_health_bar.value = floating_health
		n_back_health_bar.value = n_player.health
		n_back_health_bar.tint_progress = HEAL_COLOR
	else:
		floating_health += clamp(n_player.health - floating_health, -STATUS_MATCH_RATE * delta, \
				STATUS_MATCH_RATE * delta)
		n_front_health_bar.value = n_player.health
		n_back_health_bar.value = floating_health
		n_back_health_bar.tint_progress = DAMAGE_COLOR
	if floating_energy < n_player.energy:
		floating_energy += clamp(n_player.energy - floating_energy, -STATUS_MATCH_RATE * delta, \
				STATUS_MATCH_RATE * delta)
		n_front_energy_bar.value = floating_energy
		n_back_energy_bar.value = n_player.energy
		n_back_energy_bar.tint_progress = REPLENISH_COLOR
	else:
		floating_energy += clamp(n_player.energy - floating_energy, -STATUS_MATCH_RATE * delta, \
				STATUS_MATCH_RATE * delta)
		n_front_energy_bar.value = n_player.energy
		n_back_energy_bar.value = floating_energy
		n_back_energy_bar.tint_progress = DRAIN_COLOR
	
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


