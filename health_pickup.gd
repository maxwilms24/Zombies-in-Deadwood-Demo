extends Area2D

@export var health_amount = 25

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("players"):
		if body.has_method("heal"):
			body.heal(health_amount)
	
	if body.has_method("play_pickup_sound"):body.play_pickup_sound()
	queue_free()
