extends CharacterBody2D

signal health_changed(new_health)
signal ammo_changed(current_ammo, max_ammo)
signal money_changed(new_money)



var speed = 500
var friction = 0.1
var acceleration = 0.2

var has_wonder_weapon = false

var bullet_scene = preload("res://Bullet.tscn")
var laser_beam_scene = preload("res://laser_beam.tscn") 
var current_laser = null
@onready var shootpart = $Shootpart
@onready var is_reloading = false
@onready var sfx_shoot: AudioStreamPlayer2D = $sfx_shoot
@onready var sfx_reload: AudioStreamPlayer2D = $sfx_reload
@onready var sfx_reload_bar: AudioStreamPlayer2D = $sfx_reload_bar

const PISTOL_MAX_AMMO = 8
const BAR_MAX_AMMO = 30

@onready var pistol_ammo = PISTOL_MAX_AMMO
@onready var bar_ammo = BAR_MAX_AMMO
@onready var sfx_pickup: AudioStreamPlayer = $sfx_pickup
@onready var sfx_buy_sound: AudioStreamPlayer = $sfx_buy_sound
@onready var sfx_footsteps: AudioStreamPlayer2D = $sfx_footsteps 

var has_bar = false
var current_weapon = 1 

@onready var reload_timer = $ReloadTimer
@onready var fire_rate_timer: Timer = $FireRateTimer

@export var cowboy_sprite_texture: Texture2D
@export var bar_sprite_texture: Texture2D
@export var wonder_weapon_sprite_texture: Texture2D
@onready var player_sprite: Sprite2D = $PlayerSprite

@export var maxHealth = 100
@onready var currentHealth: int = maxHealth
var money = 0

func purchase_bar(cost: int) -> bool:
	if money >= cost and not has_bar:
		money -= cost
		money_changed.emit(money)
		sfx_buy_sound.play()
		
		has_bar = true
		bar_ammo = BAR_MAX_AMMO 
		switch_weapon(2) 
		
		return true
	return false

func purchase_wonder_weapon(cost: int) -> bool:
	if money >= cost and not has_wonder_weapon:
		spend_money(cost)
		has_wonder_weapon = true
		switch_weapon(3)
		print("WonderWapen gekocht!")
		sfx_buy_sound.play() 
		return true
	return false

func add_money(amount: int):
	money += amount
	money_changed.emit(money)

func take_damage(amount: int):
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.3).from(Color.RED)
	
	currentHealth -= amount
	if currentHealth < 0:
		currentHealth = 0
	
	health_changed.emit(currentHealth)

	if currentHealth <= 0:
		get_tree().call_group("enemies", "queue_free")
		get_tree().change_scene_to_file("res://game_over_menu.tscn")

func _ready():
	health_changed.emit(currentHealth)
	switch_weapon(1) 

func get_input():
	var input = Vector2.ZERO
	if Input.is_action_pressed('right'):
		input.x += 1
	if Input.is_action_pressed('left'):
		input.x -= 1
	if Input.is_action_pressed('down'):
		input.y += 1
	if Input.is_action_pressed('up'):
		input.y -= 1
	return input

func switch_weapon(weapon_number: int):
	if (weapon_number == 2 and not has_bar) or \
	   (weapon_number == 3 and not has_wonder_weapon) or \
	   weapon_number == current_weapon:
		return

	current_weapon = weapon_number
	
	if current_weapon == 1: 
		player_sprite.texture = cowboy_sprite_texture
		ammo_changed.emit(pistol_ammo, PISTOL_MAX_AMMO)
	elif current_weapon == 2: 
		player_sprite.texture = bar_sprite_texture
		ammo_changed.emit(bar_ammo, BAR_MAX_AMMO)
	elif current_weapon == 3: 
		player_sprite.texture = wonder_weapon_sprite_texture
		ammo_changed.emit(-1, -1) 

func shoot():
	if (current_weapon == 1 and pistol_ammo <= 0) or \
	   (current_weapon == 2 and bar_ammo <= 0):
		return 

	if current_weapon == 1:
		pistol_ammo -= 1
		ammo_changed.emit(pistol_ammo, PISTOL_MAX_AMMO)
	elif current_weapon == 2:
		bar_ammo -= 1
		ammo_changed.emit(bar_ammo, BAR_MAX_AMMO)
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = shootpart.global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().root.add_child(bullet)
	sfx_shoot.play()


func _physics_process(_delta):
	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)

	var mouse_position = get_global_mouse_position()
	var direction_to_mouse = (mouse_position - global_position).normalized()
	rotation = direction_to_mouse.angle()
	
	if direction.length() > 0 and not sfx_footsteps.playing:
		sfx_footsteps.play()
	elif direction.length() == 0 and sfx_footsteps.playing:
		sfx_footsteps.stop()
	
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	move_and_slide()
	

	if Input.is_action_just_pressed("switch_to_weapon_1"):
		switch_weapon(1)
	if Input.is_action_just_pressed("switch_to_weapon_2"):
		switch_weapon(2)
	if Input.is_action_just_pressed("switch_to_weapon_3"):
		switch_weapon(3)
		


	# --- Schietlogica ---
	if not is_reloading and current_weapon != 3: 
		if current_weapon == 2: 
			if Input.is_action_pressed("Shoot") and fire_rate_timer.is_stopped():
				shoot()
				fire_rate_timer.start()
		else: # Pistol
			if Input.is_action_just_pressed("Shoot"):
				shoot()
	
	if current_weapon == 3:
		if Input.is_action_pressed("Shoot"):
			if not is_instance_valid(current_laser):
				current_laser = laser_beam_scene.instantiate()
				shootpart.add_child(current_laser)
		else:
			if is_instance_valid(current_laser):
				current_laser.queue_free()
				current_laser = null
	else:
		if is_instance_valid(current_laser):
			current_laser.queue_free()
			current_laser = null

	if Input.is_action_just_pressed("reload") and current_weapon != 3: 
		reload()
	
func reload():
	var is_full = false
	if current_weapon == 1 and pistol_ammo == PISTOL_MAX_AMMO:
		is_full = true
	if current_weapon == 2 and bar_ammo == BAR_MAX_AMMO:
		is_full = true
		
	if is_reloading or is_full:
		return

	is_reloading = true
	
	if current_weapon == 2: 
		sfx_reload_bar.play()
	else: 
		sfx_reload.play()
		
	reload_timer.start()

func _on_reload_timer_timeout() -> void:

	if current_weapon == 1:
		pistol_ammo = PISTOL_MAX_AMMO
		ammo_changed.emit(pistol_ammo, PISTOL_MAX_AMMO)
	elif current_weapon == 2:
		bar_ammo = BAR_MAX_AMMO
		ammo_changed.emit(bar_ammo, BAR_MAX_AMMO)
		
	is_reloading = false
	
func heal(amount: int):
	currentHealth = min(currentHealth + amount, maxHealth)
	health_changed.emit(currentHealth)
	var tween = create_tween()
	tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.3).from(Color.GREEN)
	
func play_pickup_sound():
	sfx_pickup.play()

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		sfx_buy_sound.play()
		
		return true
	else: 
		return false
