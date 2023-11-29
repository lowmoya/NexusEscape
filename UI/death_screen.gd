extends CanvasLayer


func _on_try_again_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_exit_pressed():
	get_tree().quit()
