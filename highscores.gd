extends Control

@onready var scores_container = $ScoresContainer
@onready var back_button = $BackButton 

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	MusicPlayer.play_music()
	
	var scores = GameManager.high_scores

	if scores.is_empty():
		var label = Label.new()
		label.text = "Nog geen scores behaald."
		scores_container.add_child(label)
	else:
		var i = 1
		for score in scores:
			var label = Label.new()
			label.text = "%s. %s - Wave %s" % [i, score.name, int(score.wave)]
			label.add_theme_color_override("font_color", Color.BLACK)
			scores_container.add_child(label)
			i += 1



func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
