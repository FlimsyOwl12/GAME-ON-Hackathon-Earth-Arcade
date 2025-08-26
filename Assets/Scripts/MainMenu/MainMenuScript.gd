extends Control

# Audio Players
@onready var play_click = $PLAY/PlayClickSound
@onready var option_click = $OPTION/OptionClickSound
@onready var exit_click = $EXIT/ExitClickSound
@onready var return_click = get_node("OptionBoard/MarginContainerOptionBoard/TextureRect/RETURN/ReturnClickSound")

# UI Boards
@onready var option_board = $OptionBoard
@onready var exit_board = $ExitBoard
@onready var modal_blocker = $ModalBlocker

# Sliders
@onready var music_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/BGMusicSlider
@onready var sfx_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/SoundEffectSlider

# ExitBoard Buttons
@onready var yes_button = $ExitBoard/MarginContainerExitBoard/TextureRect/YES
@onready var no_button = $ExitBoard/MarginContainerExitBoard/TextureRect/NO

# SFX Players
@onready var sfx_players = [
	play_click,
	option_click,
	exit_click,
	return_click
]

# Background music stream
var bg_music := preload("res://Assets/BackgroundMusic/RetroBGMusic.ogg")

func _ready():
	print("MainMenu ready — initializing UI and audio.")

	# Ensure FadeManager's ColorRect doesn't block input
	if FadeManager and FadeManager.has_node("ColorRect"):
		var fade_rect := FadeManager.get_node("ColorRect") as ColorRect
		if fade_rect:
			fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			fade_rect.color.a = 0.0
			print("FadeManager ColorRect set to transparent.")

	# Initial visibility
	option_board.visible = false
	exit_board.visible = false
	modal_blocker.visible = false
	print("Modal blocker and boards hidden.")

	# Initialize sliders
	music_slider.value = music_slider.max_value
	sfx_slider.value = sfx_slider.max_value
	print("Sliders initialized — music:", music_slider.value, "sfx:", sfx_slider.value)

	# Connect slider signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)

	# Set initial volume levels
	AudioManager.set_music_volume(music_slider.value, music_slider.max_value)
	AudioManager.set_sfx_volume(sfx_slider.value, sfx_slider.max_value)
	print("Initial volume levels applied.")

	# Start music if not already playing
	if AudioManager.music_stream != bg_music:
		print("Starting background music with fade-in...")
		await AudioManager.play_music_stream(bg_music, 2.0)
		AudioManager.apply_music_volume(AudioManager.music_player)
		print("Background music playing:", bg_music.resource_path)

# Play button logic
func _on_play_pressed():
	if not modal_blocker.visible:
		play_click.play()
		print("Play button clicked — fading out music.")
		
		FadeManager.fade_and_change_scene("res://Scenes/cutscenes/cutscene1.tscn")
		
		await AudioManager.fade_out_music(-80.0, 2.0)
		print("Music faded out. Transitioning to cutscene1.")

		

# Option button logic
func _on_option_pressed():
	if not modal_blocker.visible:
		option_click.play()
		option_board.visible = true
		modal_blocker.visible = true
		print("Option menu opened.")

# Exit button logic
func _on_exit_pressed():
	if not modal_blocker.visible:
		exit_click.play()
		exit_board.visible = true
		modal_blocker.visible = true
		print("Exit confirmation opened.")

# Return from OptionBoard
func _on_return_pressed():
	return_click.play()
	option_board.visible = false
	modal_blocker.visible = false
	print("Returned from Option menu.")

# Confirm exit
func _on_yes_pressed() -> void:
	exit_click.play()
	print("Exit confirmed — quitting game.")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

# Cancel exit
func _on_no_pressed() -> void:
	return_click.play()
	exit_board.visible = false
	modal_blocker.visible = false
	print("Exit canceled.")

# Music slider handler
func _on_music_slider_changed(value):
	AudioManager.set_music_volume(value, music_slider.max_value)
	print("Music volume changed:", value)

# SFX slider handler
func _on_sfx_slider_changed(value):
	AudioManager.set_sfx_volume(value, sfx_slider.max_value)
	for player in sfx_players:
		AudioManager.apply_sfx_volume(player)
	print("SFX volume changed:", value)

# SFX preview
func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.apply_sfx_volume(option_click)
		option_click.play()
		print("SFX preview played.")
