extends ProgressBar

func _ready():
	var player = get_tree().get_first_node_in_group("players")

	if not player:
		return

	max_value = player.maxHealth
	value = player.currentHealth
	player.health_changed.connect(update_health_bar)

func update_health_bar(new_health):
	value = new_health
