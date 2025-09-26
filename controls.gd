extends Control


func _on_menu_pressed() -> void:
		get_tree().change_scene_to_file("res://menu.tscn")
		
func _ready():
	MusicPlayer.play_music()
