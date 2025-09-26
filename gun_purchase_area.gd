extends Area2D

@export var gun_name: String = "BAR automatic rifle"
@export var gun_cost: int = 500

@onready var prompt_label: Label = $CanvasLayer/PromptLabel

var player_in_area = null

func _ready():
	prompt_label.text = "Buy %s for %s points? (Press Enter)" % [gun_name, gun_cost]
	prompt_label.hide()

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"): 
		if player_in_area.purchase_bar(gun_cost):
			prompt_label.hide()
			set_process(false) 

func _on_body_entered(body):
	if body.is_in_group("players"):
		if not body.has_bar:
			prompt_label.show()
			player_in_area = body

func _on_body_exited(body):
	if body.is_in_group("players"):
		prompt_label.hide()
		player_in_area = null
