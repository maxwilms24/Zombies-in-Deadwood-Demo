extends CanvasLayer

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		
		get_tree().paused = false
		
		queue_free()
