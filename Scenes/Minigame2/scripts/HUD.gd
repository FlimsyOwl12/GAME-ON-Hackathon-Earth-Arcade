extends CanvasLayer

# Load your pause menu scene into a variable
var pause_menu_scene = preload("res://scenes/pause_menu.tscn") # Make sure this path is correct

func _on_pause_button_pressed():
	# Check if the pause menu isn't already open
	if not get_tree().get_root().has_node("PauseMenu"):
		var pause_menu_instance = pause_menu_scene.instantiate()
		# Give it a consistent name so we can check for it
		pause_menu_instance.name = "PauseMenu" 
		get_tree().get_root().add_child(pause_menu_instance)

func _unhandled_input(event):
	# Check if the "pause" action we just created was pressed
	if event.is_action_pressed("pause"):
		
		# Check if the pause menu is already open
		if get_tree().get_root().has_node("PauseMenu"):
			# If it is, find it and tell it to close
			var menu = get_tree().get_root().get_node("PauseMenu")
			menu._on_resume_button_pressed() # This calls the resume function in PauseMenu.gd
		else:
			# If the menu is not open, call the function to open it
			_on_pause_button_pressed()
