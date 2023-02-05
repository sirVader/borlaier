extends KinematicBody2D


onready var player: KinematicBody2D = get_parent().get_parent().get_node("Player")
onready var agent: NavigationAgent2D = $NavigationAgent2D
onready var nav_timer: Timer = $NavTimer
onready var attack_timer: Timer = $AttackTimer
onready var detection_ray_1: RayCast2D = $DetectionRay1
onready var detection_ray_2: RayCast2D = $DetectionRay2
onready var detection_area: Area2D = $DetectionArea
onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D


var speed: int = 250
var healt: int = 100
var velocity: Vector2 = Vector2.ZERO

var target_position: Vector2 = Vector2.ZERO

# Accepted states: Idling, Hunting
var state: String = "Hunting"


func _ready() -> void:
	animated_sprite.frame = 0


func _physics_process(delta: float) -> void:
	if healt <= 0:
		cpu_particles_2d.emitting = true
		animated_sprite.visible = false
		$DamageArea/CollisionShape.disabled = true
		$CollisionShape.disabled = true
		yield(get_tree().create_timer(2), "timeout")
		queue_free()
	
	set_state()
	
	if state == "Hunting":
		if detection_ray_1.cast_to.x <= 0:
			animated_sprite.scale.x = -0.5
		elif detection_ray_1.cast_to.x > 0:
			animated_sprite.scale.x = 0.5
		
		animated_sprite.play("default")
		target_position = player.global_position
	elif state == "Idling":
		animated_sprite.stop()
		animated_sprite.frame = 0
		target_position = global_position
		
	move()


func move() -> void:
	if agent.is_navigation_finished():
		return
	
	var direction: Vector2 = global_position.direction_to(agent.get_next_location())
	velocity= Vector2.ZERO
	
	velocity = direction.normalized() * speed
	agent.set_velocity(velocity)


func set_state() -> void:
	detection_ray_1.add_exception(player)
	detection_ray_2.add_exception(player)
	detection_ray_1.cast_to = player.get_node("EnemyDetectionNode1").global_position - global_position
	detection_ray_2.cast_to = player.get_node("EnemyDetectionNode2").global_position - global_position
	
	
	if detection_ray_1.get_collider() == player.get_node("PlayerHitbox") or detection_ray_2.get_collider() == player.get_node("PlayerHitbox"):
		state = "Hunting"
	elif player.get_node("PlayerHitbox") in detection_area.get_overlapping_areas():
		state = "Hunting"
	else:
		state = "Idling"


func _on_NavigationAgent2D_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = move_and_slide(velocity)


func _on_DamageArea_body_entered(body: Node) -> void:
	if body.is_in_group("Bullet"):
		healt -= body.damage_output
		body.queue_free()


func _on_DamageArea_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Grenade"):
		healt -= area.get_parent().damage_output
	
	if area.get_parent().is_in_group("Player"):
		attack_timer.start()


func _on_DamageArea_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Player"):
		attack_timer.stop()


func _on_NavTimer_timeout() -> void:
	agent.set_target_location(target_position)


func _on_AttackTimer_timeout() -> void:
	PlayerGlobals.player_healt -= 25
