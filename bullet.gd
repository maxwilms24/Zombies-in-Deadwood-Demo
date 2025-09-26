extends CharacterBody2D

const SPEED = 3000 
var direction: Vector2

func _ready():
	velocity = direction * SPEED
	rotation = direction.angle()


func _physics_process(_delta):
	var collision = move_and_collide(velocity * _delta)

	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("enemies"):
			collider.take_damage(25) 

		queue_free() 
