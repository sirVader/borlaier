extends RigidBody2D


var damage_output: int


func _on_Bullet_body_entered(body: Node) -> void:
	if !body.is_in_group("Player"):
		queue_free()


func _on_LifeTimer_timeout() -> void:
	queue_free()