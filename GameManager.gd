extends Node

signal all_boxes_activated

const TOTAL_BOXES_NEEDED = 3
var activated_boxes = 0

var final_stage_unlocked = false

var current_wave = 0
var high_scores = []
const SAVE_PATH = "user://highscores.json"

func _ready():
	load_high_scores()

func save_high_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var json_string = JSON.stringify(high_scores)
	file.store_string(json_string)
	print("Highscores opgeslagen!")

func load_high_scores():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		var data = JSON.parse_string(json_string)
		if typeof(data) == TYPE_ARRAY:
			high_scores = data
			print("Highscores geladen!")

func add_high_score(player_name, wave):
	high_scores.append({"name": player_name, "wave": wave})
	high_scores.sort_custom(func(a, b): return a.wave > b.wave)
	if high_scores.size() > 10:
		high_scores.resize(10)
	
	save_high_scores()

func soul_box_activated():
	activated_boxes += 1
	if activated_boxes >= TOTAL_BOXES_NEEDED:
		all_boxes_activated.emit()

func reset_game():
	activated_boxes = 0
	current_wave = 0
	
func clear_high_scores():
	high_scores.clear() 
	
	var save_path = "user://highscores.json"
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		print("Highscore-bestand verwijderd!")
