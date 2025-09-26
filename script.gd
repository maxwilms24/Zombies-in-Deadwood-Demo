extends Node2D

@export var voice_lines: Array[AudioStream]
var enemy_scene = preload("res://enemy.tscn")
@onready var player = $player
@onready var spawn_timer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var spawn_points = get_tree().get_nodes_in_group("spawn_locations")
@onready var sfx_ambience: AudioStreamPlayer = $sfx_ambience
@onready var wave_label = $CanvasLayer/WaveLabel
@onready var sfx_start_round: AudioStreamPlayer = $sfx_Start_round
@onready var sfx_round_end: AudioStreamPlayer = $sfx_Round_end
@export var wonder_weapon_purchase_area: Area2D
var pause_menu_scene = preload("res://pause_menu.tscn")

var wave_number = 0
var enemies_to_spawn = 0
var enemies_spawned = 0
var enemies_alive = 0


func _ready() -> void:
	wonder_weapon_purchase_area.hide()
	GameManager.all_boxes_activated.connect(_on_all_boxes_activated)
	MusicPlayer.stop_music()
	sfx_ambience.play()
	print("DEBUG: _ready() is aangeroepen.") 
	if spawn_points.is_empty():
		print("ERROR: Geen spawnlocaties gevonden in _ready()!")
	start_next_wave()

func start_next_wave() -> void:
	sfx_start_round.play()
	wave_number += 1
	GameManager.current_wave = wave_number
	wave_label.text = "Round: " + str(wave_number)
	enemies_to_spawn = 3 + (wave_number - 1) * 2
	enemies_spawned = 0
	enemies_alive = enemies_to_spawn
	
	spawn_timer.start()
	
	spawn_timer.start()
	print("DEBUG: start_next_wave() aangeroepen. Wave", wave_number, "begint. Timer is gestart.")

func spawn_enemy() -> void:
	if spawn_points.is_empty() or not is_instance_valid(player):
		return

	var space_state = get_world_2d().direct_space_state
	var visible_spawn_points = []

	for sp in spawn_points:
		var query = PhysicsRayQueryParameters2D.create(player.global_position, sp.global_position)

		query.collision_mask = 1 << 2 

		var result = space_state.intersect_ray(query)

		if result.is_empty():
			visible_spawn_points.append(sp)

	if visible_spawn_points.is_empty():
		print("WAARSCHUWING: Geen enkel spawn point met vrije zichtlijn gevonden. Gebruik de oude methode.")
		var chosen_spawn_point = spawn_points.pick_random()
		var enemy = enemy_scene.instantiate()
		enemy.set_stats(wave_number)
		enemy.global_position = chosen_spawn_point.global_position
		add_child(enemy)
		enemy.tree_exiting.connect(_on_enemy_died)
		return

	visible_spawn_points.sort_custom(
		func(a, b):
			var player_pos = player.global_position
			var distance_a = player_pos.distance_squared_to(a.global_position)
			var distance_b = player_pos.distance_squared_to(b.global_position)
			return distance_a < distance_b
	)

	var closest_visible_points = visible_spawn_points.slice(0, 2)

	if not closest_visible_points.is_empty():
		var chosen_spawn_point = closest_visible_points.pick_random()
		var enemy = enemy_scene.instantiate()
		enemy.set_stats(wave_number)
		enemy.global_position = chosen_spawn_point.global_position
		add_child(enemy)
		enemy.tree_exiting.connect(_on_enemy_died)

func _on_spawn_timer_timeout() -> void:
	print("DEBUG: SpawnTimer timeout signaal ontvangen!") 
	if spawn_points.is_empty():
		print("ERROR: Geen spawnlocaties gevonden in _on_spawn_timer_timeout()!")
		return
		
	if enemies_spawned < enemies_to_spawn:
		spawn_enemy()
		enemies_spawned += 1
	else:
		spawn_timer.stop()

func _on_enemy_died() -> void:
	enemies_alive -= 1
	if enemies_alive <= 0:
		sfx_round_end.play()
		wave_timer.start()

func _on_wave_timer_timeout() -> void:
	start_next_wave()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			return
			
		get_viewport().set_input_as_handled()
		
		get_tree().paused = true
		
		var pause_menu = pause_menu_scene.instantiate()
		add_child(pause_menu)
		
	if event.is_action_pressed("ui_text_delete"):
		print("--- HIGHSCORES GERESET ---")
		GameManager.clear_high_scores()

func _on_all_boxes_activated():
	if not GameManager.final_stage_unlocked:
		GameManager.final_stage_unlocked = true
		
		print("DEBUG: Alle boxes zijn geactiveerd! GameManager.final_stage_unlocked is nu:", GameManager.final_stage_unlocked)
		
		wonder_weapon_purchase_area.show()
		
		print("LAATSTE FASE ONTGRENDELD!")
