extends Position2D

export (String) var weapon_path: String
export (int) var ammo_in_weapon: int
export (int) var spawn_in_time: int
export (bool) var activate_once: bool
export (bool) var active: bool

onready var weapon: = load("res://Scenes/Weapons/DroppedWeapon.tscn")


"""
Startar en timer med tid beroende på "spawn_interval"
"""

func _ready() -> void:
	$SpawnTimer.start(spawn_in_time)


"""
Lägger till vapen när timern går ut och startar ny
"""

func _on_SpawnTimer_timeout() -> void:
	if active:
		var weapon_instance = weapon.instance()
		weapon_instance.weapon_type = weapon_path
		weapon_instance.bullets_in_mag = ammo_in_weapon
		
		weapon_instance.global_position = global_position
		get_parent().add_child(weapon_instance)
		
		if activate_once:
			queue_free()
		else:
			$SpawnTimer.start(spawn_in_time)
