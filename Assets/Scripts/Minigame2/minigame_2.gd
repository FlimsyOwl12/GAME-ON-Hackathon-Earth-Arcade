extends Node2D

# Game State
var game_started: bool = false
var music_fade_triggered: bool = false

var click_stream = preload("res://Assets/SoundEffects/CLICKMenu.mp3")

var minigame_music := preload("C:/Users/JL/OneDrive/Documents/GitHub/GAME-ON-Hackathon-Earth-Arcade/Scenes/Minigame2/Sounds/G2_Music.mp3")
# UI Nodes
@onready var start_game_board := $UILayer/StartGameBoard
@onready var play_button := $UILayer/StartGameBoard/TextureRect/StartGameButton
@onready var modal_blocker := $UILayer/ModalBlocker
@onready var counter := $UILayer/BlockableUI/Counter
@onready var controls := $UILayer/BlockableUI/Controls
@onready var timer_label := $UILayer/BlockableUI/TimerLabel
@onready var player := $player

#Sound Click Effects
@onready var click_start_sfx_player = $UILayer/StartGameBoard/TextureRect/StartGameButton/StartGameButtonClickSoundEffect

func _ready() -> void:
	print("Minigame2 scene is ready.")
	Global.lock_input()

	# Pause gameplay immediately
	pause_ui_logic(true)
	pause_player(true)

	# Show modal blocker during fade-in
	modal_blocker.visible = true

	# Hide all other modals to prevent flicker
	start_game_board.visible = false
	play_button.visible = false

	# FadeManager setup
	if FadeManager and FadeManager.has_node("ColorRect"):
		var fade_rect := FadeManager.get_node("ColorRect") as ColorRect
		if fade_rect:
			fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout
	FadeManager.fade_in_only()
	await FadeManager.get_node("AnimationPlayer").animation_finished
	print("FadeManager fade-in complete.")
	
	click_start_sfx_player.stream = click_stream

	# Ensure button stays responsive
	play_button.process_mode = Node.PROCESS_MODE_ALWAYS

	_show_start_screen()
	
func _on_start_game_button_pressed() -> void:
	click_start_sfx_player.play()
	print("Start button pressed — starting game")
	Global.unlock_input()
	modal_blocker.visible = false
	start_game_board.visible = false
	play_button.visible = false
	game_started = true

	pause_ui_logic(false)
	pause_player(false)
	
	AudioManager.set_music_volume(100, 100)
	await AudioManager.play_music_stream(minigame_music, 2.0)

func pause_ui_logic(pause: bool) -> void:   # Pause UI during fade in animation
	counter.set_process(!pause)
	controls.set_process(!pause)
	timer_label.set_process(!pause)

func pause_player(pause: bool) -> void: # Pause player controls during fade in animation
	player.set_physics_process(!pause)
	player.set_process_input(!pause)

func _show_start_screen():
	modal_blocker.visible = true
	start_game_board.visible = true
	play_button.visible = true

	play_button.focus_mode = Control.FOCUS_NONE
	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()

	print("Start screen shown.")
