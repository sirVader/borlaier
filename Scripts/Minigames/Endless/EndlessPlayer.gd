extends KinematicBody2D

signal player_dead
signal throwing_grenade

var grenade = load("res://Scenes/Weapons/Grenade.tscn")

var looking_direction: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.RIGHT

var on_weapon: bool = false
var weapon_on_ground: Node

var points: int = 0
var points_counter: int = 0

var has_gun: bool = false
var current_weapon: String = ""
var grenades_left: int = 5

export (int) var speed: int = 600


func _ready() -> void:
	Shake.shake_nodes.clear()
	Shake.shake_nodes[$PlayerCamera] = true

"""
Samma script som "Player" + extra variabler.
I denna funktion läggs även til poäng för varje 60 frames => 1 poäng/sekund.
"""

func _physics_process(_delta: float) -> void:
	points_counter += 1
	if points_counter % 60 == 0:
		points += 1
	
	weapon_pickup()
	
	throw_grenade()
	
	movment()


func movment() -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN
	if Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT
	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	
	
	# Uses two different movement scripts if player has a weapon or not
	
	# This script if the player has weapons
	if has_gun:
		if get_global_mouse_position().x < global_position.x:
			looking_direction = Vector2.LEFT
		else:
			looking_direction = Vector2.RIGHT
		
		if velocity != Vector2.ZERO:
			if looking_direction == Vector2.LEFT:
				$PlayerSprite.play("NoHandsLeft")
			elif looking_direction == Vector2.RIGHT:
				$PlayerSprite.play("NoHandsRight")
		else:
			if looking_direction == Vector2.LEFT:
				$PlayerSprite.play("NoHandsIdleLeft")
			elif looking_direction == Vector2.RIGHT:
				$PlayerSprite.play("NoHandsIdleRight")
	
	# This script if the player has no weapons
	else:
		if velocity != Vector2.ZERO:
			
			if velocity.x != 0:
				last_velocity.x = velocity.x
		
			if last_velocity.x == -1:
				$PlayerSprite.play("Left")
			elif last_velocity.x == 1:
				$PlayerSprite.play("Right")
			
		elif velocity == Vector2.ZERO:
			if last_velocity.x == -1:
				$PlayerSprite.play("IdleLeft")
			elif last_velocity.x == 1:
				$PlayerSprite.play("IdleRight")
	
	
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity)



func weapon_pickup() -> void:
	if Input.is_action_pressed("drop") and has_gun:
		has_gun = false
		
		var dropped_weapon = load("res://Scenes/Weapons/DroppedWeapon.tscn")
		dropped_weapon = dropped_weapon.instance()
		dropped_weapon.weapon_type = current_weapon
		dropped_weapon.position = position
		dropped_weapon.bullets_in_mag = PlayerGlobals.bullets_in_mag
		
		get_parent().add_child(dropped_weapon)
		
		for child in get_children():
			if child.is_in_group("Weapon"):
				child.queue_free()
	
	if Input.is_action_pressed("pick_up") and on_weapon and !has_gun:
		has_gun = true
		
		var weapon = load(weapon_on_ground.weapon_type)
		current_weapon = weapon_on_ground.weapon_type
		weapon = weapon.instance()
		weapon.position = $PlayerCamera.position
		weapon.bullets_in_mag = weapon_on_ground.bullets_in_mag
		
		add_child(weapon)
		get_parent().get_node(weapon_on_ground.get_path()).queue_free()



func throw_grenade() -> void:
	if Input.is_action_just_pressed("add_nades"):
		grenades_left += 2
	
	if Input.is_action_just_pressed("throw_grenade") and grenades_left > 0:
		grenades_left -= 1
		PlayerGlobals.holding_grenade = true
		
		var grenade_instance = grenade.instance()
		grenade_instance.global_position = $PlayerCamera.global_position
		var _error = connect("throwing_grenade", grenade_instance, "grenade_thrown")
		
		grenade_instance.player = self
		get_parent().get_parent().add_child(grenade_instance)
	
	
	if Input.is_action_just_released("throw_grenade"):
		emit_signal("throwing_grenade")
		PlayerGlobals.holding_grenade = false


func _on_PlayerHitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("DroppedWeapon"):
		weapon_on_ground = area
		on_weapon = true
	
	if area.get_parent().is_in_group("Grenade"):
		PlayerGlobals.health -= area.get_parent().damage_output
	
	# Lightning strike damage
	if area.get_parent().is_in_group("LightningStrike"):
		PlayerGlobals.health -= 80


func _on_PlayerHitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("DroppedWeapon"):
		weapon_on_ground = null
		on_weapon = false

