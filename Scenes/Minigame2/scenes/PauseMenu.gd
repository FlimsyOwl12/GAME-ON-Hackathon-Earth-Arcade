extends CanvasLayer

# Get references to the nodes using their full paths
@onready var music_slider = $ColorRect/music_SFX/MusicSlider
@onready var sfx_slider = $ColorRect/music_SFX/SFXSlider
@onready var resume_button = $ColorRect/music_SFX/resume

func _ready():
	# Pause the game as soon as this menu appears
	get_tree().paused = true

	# Set initial slider values from the audio server
	set_initial_slider_values()

func _on_resume_button_pressed():
	# Unpause the game and close the menu
	get_tree().paused = false
	queue_free()

func _on_music_slider_value_changed(value):
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(value))

func _on_sfx_slider_value_changed(value):
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(value))

func set_initial_slider_values():
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_idx))

	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_idx))
