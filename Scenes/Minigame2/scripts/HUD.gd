extends CanvasLayer

var pause_menu_scene = preload("res://Scenes/Minigame2/scenes/pause_menu.tscn") # Make sure this path is correct

# This function is for the on-screen button
func _on_pause_button_pressed():
	# Check if the menu is already open before creating a new one
	if not get_tree().get_root().has_node("PauseMenu"):
		var pause_menu_instance = pause_menu_scene.instantiate()
		pause_menu_instance.name = "PauseMenu" 
		get_tree().get_root().add_child(pause_menu_instance)

# This function is for the Escape key
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		# Check if the menu is open
		if get_tree().get_root().has_node("PauseMenu"):
			# If it is, find it and tell it to close itself
			var menu = get_tree().get_root().get_node("PauseMenu")
			menu._on_resume_button_pressed()
		else:
			# If it's not open, open it
			_on_pause_button_pressed()
