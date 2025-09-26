extends Control

@onready var money_label: Label = $Label

func _ready():
	await get_tree().create_timer(0.1).timeout

	var player = get_tree().get_first_node_in_group("players")
	if player:
		player.money_changed.connect(update_money_display)
		update_money_display(player.money)

func update_money_display(new_money: int):
	money_label.text = "$ %s" % new_money
