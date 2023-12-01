extends CanvasLayer

func _on_try_again_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false


func _on_exit_pressed():
	get_tree().quit()


func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		visible = false
		get_tree().paused = false
		process_mode = Node.PROCESS_MODE_DISABLED
