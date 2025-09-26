extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://cutscene.tscn")
	
func _ready():
	MusicPlayer.play_music()

func _on_quit_pressed() -> void:
	get_tree().quit() 


func _on_controls_pressed() -> void:
	get_tree().change_scene_to_file("res://controls.tscn")
	

func _on_highscores_pressed() -> void:
	get_tree().change_scene_to_file("res://highscores.tscn")
