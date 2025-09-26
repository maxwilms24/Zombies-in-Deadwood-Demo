extends Area2D

@export var kills_needed: int = 1
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sfx_turn_on: AudioStreamPlayer2D = $sfx_turn_on

var current_kills: int = 0
var is_active: bool = false
var zombies_in_range: Array = []

func _ready():
	sprite.texture = inactive_texture
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	print("Soul Box geïnitialiseerd. Kills nodig: ", kills_needed)

func _on_body_entered(body):
	if is_active or not body.is_in_group("enemies"):
		return
	
	zombies_in_range.append(body)
	if not body.died.is_connected(_on_zombie_died):
		body.died.connect(_on_zombie_died)
		print("DEBUG: Zombie is het gebied binnengekomen en verbonden met 'died' signaal.")

func _on_body_exited(body):
	if is_active or not body.is_in_group("enemies"):
		return
	
	if body in zombies_in_range:
		zombies_in_range.erase(body)
		if body.died.is_connected(_on_zombie_died):
			body.died.disconnect(_on_zombie_died)
			print("DEBUG: Zombie heeft het gebied verlaten en is losgekoppeld.")

func _on_zombie_died():
	current_kills += 1
	print("DEBUG: Kill geregistreerd! Totaal kills voor deze box: ", current_kills)
	
	if current_kills >= kills_needed:
		activate()

func activate():
	
	if is_active:
		return

	is_active = true
	sprite.texture = active_texture
	sfx_turn_on.play()
	print("--- SOUL BOX GEACTIVEERD! ---")
	
	GameManager.soul_box_activated()
	
	collision_shape.set_deferred("disabled", true)
