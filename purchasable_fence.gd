extends StaticBody2D

@export var cost: int = 1

@onready var prompt_label: Label = $CanvasLayer/PurchasePrompt
@onready var interaction_area: Area2D = $InteractionArea

var player_in_area = null

func _ready():
	prompt_label.text = "Buy for %s points? (Press Enter)" % cost
	prompt_label.hide()

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):
		if player_in_area.spend_money(cost):
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("players"):
		prompt_label.show()
		player_in_area = body

func _on_body_exited(body):
	if body.is_in_group("players"):
		prompt_label.hide()
		player_in_area = null
