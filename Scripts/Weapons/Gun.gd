extends Node2D


export (int) var bullet_speed: int = 3000
export (int) var magazine_size: int = 20
export (float) var fire_rate: float = 0.12
export (int) var damage: int = 10
export (bool) var auto: bool = false



var bullets_in_mag: int


var bullet = load("res://Scenes/Weapons/Bullet.tscn")
var can_fire: bool = true
var can_fire_auto: bool = true


func _input(event: InputEvent) -> void:

	if event.is_action_released("fire"):
		can_fire_auto = true


func _physics_process(_delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if get_global_mouse_position().x < global_position.x:
		scale = Vector2(1, -1)
	else:
		scale = Vector2(1, 1)
	
	
	if auto:
		can_fire_auto = true
	
	"""
	Om spelaren trycker ned ladda-omknappen och det finns utrymme i magasinet för fler kulor 
	samt att reservamunitionen är mer än 0. Laddar då om vapnet.
	"""
	
	if Input.is_action_just_pressed("reload") and bullets_in_mag < magazine_size and PlayerGlobals.bullets_left > 0 and can_fire:
		
		$GunReloadSound.play()
		reload_gun()
		
		can_fire = false
		yield(get_tree().create_timer(1.5),"timeout")
		can_fire = true
	
	"""
	Om spelaren trycker ned skjutknappen så kollas det om det finns amunition och om spelare kan skjuta.
	Skapar kulor utifrån vad skjuthastigheten på det nuvarande vapnet som spelaren håller i är satt till. 
	Skapar samt skjutljud. Ger kulorna en riktning mot musen.
	"""
	
	if Input.is_action_pressed("fire") and can_fire and can_fire_auto and bullets_in_mag > 0 and not PlayerGlobals.talking:
		can_fire_auto = false
		
		bullets_in_mag -= 1
		Stats.bullets_fired += 1
		$BulletSound.play()
		$MuzzleFlash.frame = 0
		$MuzzleFlash.play("deafult")
		var bullet_instance = bullet.instance()
		bullet_instance.global_position = $BulletSpawn.global_position
		bullet_instance.rotation = rotation
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		bullet_instance.damage_output = damage
		get_parent().get_parent().add_child(bullet_instance)
		
		
		# Regulates rate of fire
		can_fire = false
		yield(get_tree().create_timer(fire_rate),"timeout")
		can_fire = true
	
	elif Input.is_action_pressed("fire") and can_fire and can_fire_auto and bullets_in_mag == 0:
		can_fire_auto = false
		
		$GunClickSound.play()
		
		# Regulates rate of fire
		can_fire = false
		yield(get_tree().create_timer(fire_rate),"timeout")
		can_fire = true
	
	PlayerGlobals.bullets_in_mag = bullets_in_mag

"""
När vapnet laddas om förs möjliga kulor över från extraamunitionen till vapnets magasin.
"""

func reload_gun() -> void:
	for _i in range(magazine_size): 
		if PlayerGlobals.bullets_left != 0 and !bullets_in_mag >= magazine_size:
			PlayerGlobals.bullets_left -= 1
			bullets_in_mag += 1
