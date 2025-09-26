extends Control

@onready var score_label = $scoreLabel
@onready var name_input = $nameInput
@onready var submit_button = $submitbutton
@onready var restart_button = $restartbutton 
@onready var main_menu_button = $main_menu_button 
@onready var sfx_game_over: AudioStreamPlayer2D = $sfx_game_over

func _ready():
	sfx_game_over.play()
	score_label.text = "%s" % GameManager.current_wave
	name_input.grab_focus()

	submit_button.pressed.connect(_on_submit_pressed)


func _on_submit_pressed():
	var player_name = name_input.text
	if not player_name.is_empty():
		GameManager.add_high_score(player_name, GameManager.current_wave)

		name_input.hide()
		submit_button.hide()

func _on_restart_pressed():
	GameManager.reset_game() 
	get_tree().change_scene_to_file("res://world.tscn")

func _on_main_menu_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://menu.tscn")
	


func _on_highscore_pressed() -> void:
		GameManager.reset_game()
		get_tree().change_scene_to_file("res://highscores.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit() 
