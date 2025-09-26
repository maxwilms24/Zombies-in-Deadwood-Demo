extends Control

@onready var start_game_button: TextureButton = $TextureButton

func _ready():
	MusicPlayer.stop_music()
	start_game_button.pressed.connect(_on_start_game_pressed)

func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
