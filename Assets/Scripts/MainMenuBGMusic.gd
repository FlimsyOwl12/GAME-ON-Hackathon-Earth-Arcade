extends Control

# 🎵 Audio Players
@onready var music_player = $AudioPlayer
@onready var play_click = $PLAY/PlayClickSound
@onready var option_click = $OPTION/OptionClickSound
@onready var exit_click = $EXIT/ExitClickSound
@onready var return_click = get_node("OptionBoard/MarginContainerOptionBoard/TextureRect/RETURN/ReturnClickSound")

# 🧩 UI Boards
@onready var option_board = $OptionBoard
@onready var exit_board = $ExitBoard
@onready var modal_blocker = $ModalBlocker  # 🛡️ Blocks input when OptionBoard or ExitBoard is open

# 🎚 Sliders
@onready var music_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/BGMusicSlider
@onready var sfx_slider = $OptionBoard/MarginContainerOptionBoard/TextureRect/SoundEffectSlider

# 🔘 ExitBoard Buttons
@onready var yes_button = $ExitBoard/MarginContainerExitBoard/TextureRect/YES
@onready var no_button = $ExitBoard/MarginContainerExitBoard/TextureRect/NO

# 🔊 Audio Players for SFX
@onready var sfx_players = [
	play_click,
	option_click,
	exit_click,
	return_click
]

# 🎬 Fade Animation
@onready var fade_anim = $FadeLayer/FadeOut
@onready var fade_rect = $FadeLayer/ColorRect  # 🖼️ Fade overlay

func _ready():
	# 🛠️ Fix: Make fade overlay transparent to input
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Initial visibility
	option_board.visible = false
	exit_board.visible = false
	modal_blocker.visible = false

	# Set sliders to max
	music_slider.value = music_slider.max_value
	sfx_slider.value = sfx_slider.max_value

	# Connect slider signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	# Connect fade animation signal
	fade_anim.animation_finished.connect(_on_animation_finished)

	# Start music and apply initial volume
	music_player.volume_db = -80
	music_player.play()
	_on_music_slider_changed(music_slider.value)
	_on_sfx_slider_changed(sfx_slider.value)

# ▶️ Play button
func _on_play_pressed():
	if not modal_blocker.visible:
		play_click.play()
		fade_anim.play("FadeOut")  # Trigger fade-out animation

# ⚙️ Option button
func _on_option_pressed():
	if not modal_blocker.visible:
		option_click.play()
		option_board.visible = true
		modal_blocker.visible = true

# ❌ Exit button
func _on_exit_pressed():
	if not modal_blocker.visible:
		exit_click.play()
		exit_board.visible = true
		modal_blocker.visible = true

# 🔙 Return from OptionBoard
func _on_return_pressed():
	return_click.play()
	option_board.visible = false
	modal_blocker.visible = false

# ✅ YES pressed (quit game)
func _on_yes_pressed() -> void:
	get_tree().quit()

# ❎ NO pressed (cancel exit)
func _on_no_pressed() -> void:
	return_click.play()
	exit_board.visible = false
	modal_blocker.visible = false

# 🎚 Adjust background music volume
func _on_music_slider_changed(value):
	var ratio = clamp(value / music_slider.max_value, 0.0, 1.0)
	music_player.volume_db = linear_to_db(ratio)

# 🔊 Adjust sound effects volume
func _on_sfx_slider_changed(value):
	var ratio = clamp(value / sfx_slider.max_value, 0.0, 1.0)
	var db = linear_to_db(ratio)
	for player in sfx_players:
		if player is AudioStreamPlayer:
			player.volume_db = db

# 🎬 Handle fade-out completion
func _on_animation_finished(anim_name):
	if anim_name == "FadeOut":
		get_tree().change_scene_to_file("res://Scenes/cutscenes/cutscene1.tscn")
