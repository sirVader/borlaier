extends Node

var health: int = 100
var dead: bool = false
var has_gun: bool = true

var talking: bool = false

var coins: int = 0

var magazine_size: int
var bullets_in_mag: int 
var bullets_in_mag_main: int 
var bullets_left: int = 200
var bullets_left_main: int = bullets_left

var grenades_left: int = 2
var holding_grenade: bool = false

var current_weapon: String = "res://Scenes/Weapons/AssultRifle.tscn"

var elevator_floor_access: Array = [0, 1, 2, 3]


func _ready() -> void:
	magazine_size = load(current_weapon).instance().magazine_size
	bullets_in_mag = magazine_size


func _physics_process(delta: float) -> void:
	if health <= 0 and !dead:
		dead = true


# Needs to be a function for dialogic to access
func set_talking_state() -> void:
	talking = false


func dialogic_get_coins() -> void:
	print(coins)
	Dialogic.set_variable("PlayerCoins", str(coins))


func give_next_keycard(amount: String) -> void:
	coins -= int(amount)
	elevator_floor_access.append(elevator_floor_access.size())
	print(elevator_floor_access)
	Dialogic.set_variable("KeycardBought", "true")
