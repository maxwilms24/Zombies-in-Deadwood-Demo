extends Area2D

const COST = 500
@onready var prompt_label: Label = $CanvasLayer/PromtLabel

var player_in_area = null

func _ready():
	prompt_label.hide()

func _on_body_entered(body):
	if body.is_in_group("players"):
		player_in_area = body
		if GameManager.final_stage_unlocked:
			if not player_in_area.has_wonder_weapon:
				prompt_label.text = "Buy the wonder weapon for %s points? (Press Enter)" % COST
				prompt_label.show()
		else:
			prompt_label.text = "Locked - activate all of the Soul Boxes"
			prompt_label.show()

func _process(_delta):
	if player_in_area and GameManager.final_stage_unlocked and Input.is_action_just_pressed("ui_accept"):
		if player_in_area.purchase_wonder_weapon(COST):
			prompt_label.hide()
			set_process(false)

func _on_body_exited(body):
	if body.is_in_group("players"):
		prompt_label.hide()
		player_in_area = null
