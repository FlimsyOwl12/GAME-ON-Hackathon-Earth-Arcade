extends Control

# Audio Players
@onready var music_player = $AudioPlayer
@onready var play_click = $PLAY/PlayClickSound
@onready var option_click = $OPTION/OptionClickSound
@onready var exit_click = $EXIT/ExitClickSound
@onready var return_click = get_node("OptionBoard/MarginContainerOptionBoard/TextureRect/RETURN/ReturnClickSound")

# UI Boards
@onready var option_board = $OptionBoard
@onready var exit_board = $ExitBoard
@onready var modal_blocker = $ModalBlocker  # Prevents input when OptionBoard or ExitBoard is active

# Sliders
@onready var music_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/BGMusicSlider
@onready var sfx_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/SoundEffectSlider

# ExitBoard Buttons
@onready var yes_button = $ExitBoard/MarginContainerExitBoard/TextureRect/YES
@onready var no_button = $ExitBoard/MarginContainerExitBoard/TextureRect/NO

# Audio Players for Sound Effects
@onready var sfx_players = [
	play_click,
	option_click,
	exit_click,
	return_click
]

# Fade Animation
@onready var fade_anim = $FadeLayer/FadeOut
@onready var fade_rect = $FadeLayer/ColorRect  # Overlay used for fade transitions

func _ready():
	# Ensure fade overlay does not block mouse input
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Set initial visibility of UI elements
	option_board.visible = false
	exit_board.visible = false
	modal_blocker.visible = false

	# Initialize sliders to maximum values
	music_slider.value = music_slider.max_value
	sfx_slider.value = sfx_slider.max_value

	# Connect slider change signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	# Connect slider drag end signal for sound effect preview
	sfx_slider.drag_ended.connect(_on_sfx_slider_drag_ended)

	# Connect fade animation completion signal
	fade_anim.animation_finished.connect(_on_animation_finished)

	# Start background music and apply initial volume settings
	music_player.volume_db = -80
	music_player.play()
	_on_music_slider_changed(music_slider.value)
	_on_sfx_slider_changed(sfx_slider.value)

# Play button logic
func _on_play_pressed():
	if not modal_blocker.visible:
		play_click.play()

		# Create and configure tween for music fade-out
		var music_tween := create_tween()
		music_tween.set_trans(Tween.TRANS_LINEAR)
		music_tween.set_ease(Tween.EASE_IN_OUT)
		music_tween.tween_property(music_player, "volume_db", -80, 5.0)

		# Trigger fade-out animation
		fade_anim.play("FadeOut")

# Option button logic
func _on_option_pressed():
	if not modal_blocker.visible:
		option_click.play()
		option_board.visible = true
		modal_blocker.visible = true

# Exit button logic
func _on_exit_pressed():
	if not modal_blocker.visible:
		exit_click.play()
		exit_board.visible = true
		modal_blocker.visible = true

# Return from OptionBoard
func _on_return_pressed():
	return_click.play()
	option_board.visible = false
	modal_blocker.visible = false

# Confirm exit (YES)
func _on_yes_pressed() -> void:
	exit_click.play()
	await get_tree().create_timer(0.5).timeout  # Wait for sound effect to complete
	get_tree().quit()

# Cancel exit (NO)
func _on_no_pressed() -> void:
	return_click.play()
	exit_board.visible = false
	modal_blocker.visible = false

# Update background music volume based on slider value
func _on_music_slider_changed(value):
	var ratio = clamp(value / music_slider.max_value, 0.0, 1.0)
	music_player.volume_db = linear_to_db(ratio)

# Update sound effects volume based on slider value
func _on_sfx_slider_changed(value):
	var ratio = clamp(value / sfx_slider.max_value, 0.0, 1.0)
	var db = linear_to_db(ratio)
	for player in sfx_players:
		if player is AudioStreamPlayer:
			player.volume_db = db

# Play a sound effect when the slider drag ends
func _on_sfx_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		# Play a sample sound effect to preview volume
		if option_click is AudioStreamPlayer:
			option_click.play()

# Handle completion of fade-out animation
func _on_animation_finished(anim_name):
	if anim_name == "FadeOut":
		await get_tree().create_timer(0.5).timeout  # Optional delay to allow audio fade
		get_tree().change_scene_to_file("res://Scenes/cutscenes/cutscene1.tscn")
