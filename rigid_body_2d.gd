extends RigidBody2D

var bullet_speed = 2000

func _ready():

	get_node("/root/BulletTimer").start()
	

	linear_velocity = Vector2(bullet_speed, 0).rotated(rotation)
	
func _on_timer_timeout():

	queue_free()
