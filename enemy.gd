extends CharacterBody2D

signal died

@export var max_health = 50
@onready var current_health = max_health

var health_item_scene = preload("res://health_pickup.tscn")

@export var death_sounds: Array[AudioStream]
@export var soul_death_sound: AudioStream

var can_attack = true
@onready var attack_cooldown_timer = $AttackCooldownTimer
@export var damage = 15

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var death_sound_player: AudioStreamPlayer2D = $DeathSoundPlayer

@onready var player = get_tree().get_first_node_in_group("players")
const SPEED = 200

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var is_dying = false

func set_stats(wave_number: int):
	max_health = 50 + (wave_number - 1) * 10
	current_health = max_health
	damage = 15 + (wave_number / 2.0) * 5 

func take_damage(amount: int):
	if has_node("PlayerSprite"):
		var tween = create_tween()
		tween.tween_property($PlayerSprite, "modulate", Color.WHITE, 0.3).from(Color.RED)
		
	if is_dying:
		return
		
	current_health -= amount

	if current_health <= 0:
		is_dying = true
		
		died.emit()
		player.add_money(100)
		
		if randf() < 0.1:
			var health_item = health_item_scene.instantiate()
			health_item.global_position = self.global_position
			get_tree().current_scene.add_child(health_item)

		$CollisionShape2D.set_deferred("disabled", true)

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property($PlayerSprite , "modulate", Color(1, 1, 1, 0), 0.5)
		tween.tween_property($PlayerSprite , "scale", Vector2.ZERO, 0.5)

		var is_in_soul_box_area = false
		for area in $ProximityDetector.get_overlapping_areas():
			if area.is_in_group("soul_boxes"):
				is_in_soul_box_area = true
				break

		var sound_to_play = null
		if is_in_soul_box_area and soul_death_sound:
			sound_to_play = soul_death_sound
		elif not death_sounds.is_empty():
			sound_to_play = death_sounds.pick_random()

		if sound_to_play:
			death_sound_player.stream = sound_to_play
			death_sound_player.play()
			# Wacht op het geluid
			print("DEBUG: Wacht op geluid...")
			await death_sound_player.finished
			print("DEBUG: Geluid is klaar.")


		queue_free()

func _physics_process(_delta: float) -> void:
	if is_dying:
		return
		
	var next_point = nav_agent.get_next_path_position()
	var dir = (next_point - global_position).normalized()
	velocity = dir * SPEED
	
	move_and_slide()
	look_at(player.global_position)
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision:
			var collider = collision.get_collider()
			if collider.is_in_group("players") and can_attack:
				collider.take_damage(damage)
				can_attack = false
				attack_cooldown_timer.start()
				audio_stream_player_2d.play()

func _on_attack_cooldown_timer_timeout():
	can_attack = true

func makepath() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	makepath()
