extends Sprite


export (int) var bullet_speed = 1500
export (int) var magasine_size = 20
export (float) var fire_rate = 0.12
export (int) var damage = 10
export (bool) var auto = false



var bullets_in_mag: int


var bullet = load("res://Scenes/Bullet.tscn")
var can_fire: bool = true
var can_fire_auto: bool = true


func _ready() -> void:
	reload_gun()


func _input(event: InputEvent) -> void:

	if event.is_action_released("fire"):
		can_fire_auto = true
		print("can fire")


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if get_global_mouse_position().x < global_position.x:
		scale = Vector2(1, -1)
	else:
		scale = Vector2(1, 1)
	
	
	if auto:
		can_fire_auto = true
	
	
	if Input.is_action_just_pressed("reload") and bullets_in_mag < magasine_size and PlayerGlobals.bullets_left > 0 and can_fire:
		
		$GunReloadSound.play()
		reload_gun()
		
		can_fire = false
		yield(get_tree().create_timer(1.5),"timeout")
		can_fire = true
	
	
	if Input.is_action_pressed("fire") and can_fire and can_fire_auto and bullets_in_mag > 0:
		can_fire_auto = false
		
		bullets_in_mag -= 1
		$BulletSound.play()
		var bullet_instance = bullet.instance()
		bullet_instance.global_position = $BulletSpawn.global_position
		bullet_instance.rotation = rotation
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_node("/root/SceneController").get_child(1).add_child(bullet_instance)
		
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



func reload_gun() -> void:
	for i in range(magasine_size): 
		if PlayerGlobals.bullets_left != 0 and !bullets_in_mag >= magasine_size:
			PlayerGlobals.bullets_left -= 1
			bullets_in_mag += 1
