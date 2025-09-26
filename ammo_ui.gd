extends Control

@onready var ammo_label: Label = $AmmoLabel

func _ready():
	await get_tree().create_timer(0.01).timeout
	var player = get_tree().get_first_node_in_group("players")
	if player:
		player.ammo_changed.connect(update_ammo_display)

func update_ammo_display(new_ammo, max_ammo):
	if new_ammo == -1:
		ammo_label.text = "∞"
	else:
		ammo_label.text = "%s / %s" % [new_ammo, max_ammo]
