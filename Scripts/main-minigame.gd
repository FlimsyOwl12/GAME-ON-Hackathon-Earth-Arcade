extends Node2D

# Game State
var score: int = 0
var current_trash: String = ""
var time_left: float = 0.0
var game_started: bool = false
var music_fade_triggered: bool = false
var cursor_texture = preload("res://Assets/PixelArtAssets/Minigame1 Assets/Cursor-removebg-preview.png")
@export var bullet_scene = preload("res://Scenes/Minigame1/trash.tscn")

# Audio Stream
var click_stream = preload("res://Assets/SoundEffects/CLICKMenu.mp3")
var minigame_music := preload("res://Assets/BackgroundMusic/KingLebron.ogg")

# UI Nodes
@onready var timer_label = $TimerLabel
@onready var score_label = $ScoreLabel
@onready var goal_popup = $GoalPopup
@onready var start_button = $StartGameBoard/MarginContainer/TextureRect/StartGameButton
@onready var times_up_button = $TimesUpBoard/MarginContainer/TextureRect/TimesUpButton
@onready var modal_blocker = $ModalBlocker
@onready var start_game_board = $StartGameBoard
@onready var times_up_board = $TimesUpBoard
@onready var trash = "res://Scenes/Minigame1/trash.tscn"

# Audio Players
@onready var click_start_sfx_player = $StartGameBoard/MarginContainer/TextureRect/StartGameButton/StartGameButtonClickSoundEffect
@onready var click_times_up_sfx_player = $TimesUpBoard/MarginContainer/TextureRect/TimesUpButton/TimesUpButtonClickSoundEffect

func _ready():
	print("Minigame1 scene is ready.")
	Global.lock_input()

	_reset_ui()
	_show_start_screen()

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

	# Audio setup
	click_start_sfx_player.stream = click_stream
	click_times_up_sfx_player.stream = click_stream

	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	times_up_button.process_mode = Node.PROCESS_MODE_ALWAYS

	# Signal connections
	$Recylable.scored.connect(_on_Hoop_scored)
	$Recylable.wrong_trash.connect(_on_wrong)
	$"Non-Biodegradable".scored.connect(_on_Hoop_scored)
	$"Non-Biodegradable".wrong_trash.connect(_on_wrong)
	$Biodegradable.scored.connect(_on_Hoop_scored)
	$Biodegradable.wrong_trash.connect(_on_wrong)

	Input.set_custom_mouse_cursor(cursor_texture)

	_pause_game(true)

# Score Handling
func _on_Hoop_scored():
	if Global.input_locked: return
	score += 1
	score_label.text = "Score: %d" % score
	goal_popup.text = "Good job! Correct Trashcan"

func _on_wrong():
	if Global.input_locked: return
	score = max(score - 1, 0)
	score_label.text = "Score: %d" % score
	goal_popup.text = "Oh no! Wrong Trashcan"

# Trash Display
func update_display_label():
	if $DisplayTrash:
		$DisplayTrash.text = current_trash.capitalize()

# Timer
func _process(delta):
	if Global.input_locked or not game_started or get_tree().paused:
		return

	if time_left > 0:
		time_left -= delta
		timer_label.text = str(int(time_left))

		if time_left <= 3.0 and not music_fade_triggered:
			music_fade_triggered = true
			print("Triggering music fade-out...")
			AudioManager.fade_out_music(-80.0, 2.5)
	else:
		game_over()

# Game Over
func game_over():
	timer_label.text = ""
	goal_popup.text = ""
	game_started = false
	music_fade_triggered = false
	Global.lock_input()
	_pause_game(true)
	_show_times_up_screen()

# Start Button
func _on_start_game_button_pressed():
	click_start_sfx_player.play()
	await get_tree().create_timer(0.3).timeout

	_hide_all_modals()

	score = 0
	time_left = 20
	score_label.text = "Score: 0"
	timer_label.text = str(int(time_left))
	goal_popup.text = ""

	AudioManager.set_music_volume(100, 100)
	await AudioManager.play_music_stream(minigame_music, 2.0)

	Global.unlock_input()
	game_started = true
	_pause_game(false)

# Continue Button
func _on_continue_button_pressed():
	click_times_up_sfx_player.play()
	await get_tree().create_timer(0.3).timeout

	goal_popup.text = ""
	Global.unlock_input()
	game_started = true
	_pause_game(false)
	_hide_all_modals()

# Times Up Button
func _on_times_up_button_pressed():
	click_times_up_sfx_player.play()
	await get_tree().create_timer(0.5).timeout

	game_started = false
	Global.lock_input()
	_pause_game(false)

	Input.set_custom_mouse_cursor(null)
	FadeManager.fade_and_change_scene("res://Scenes/cutscenes/cutscene2.tscn")

# Utility: Pause Game
func _pause_game(state: bool):
	get_tree().paused = state
	print("Game paused:", state)

# Utility: Reset UI
func _reset_ui():
	modal_blocker.visible = false
	start_game_board.visible = false
	start_button.visible = false
	times_up_board.visible = false
	times_up_button.visible = false

# Utility: Show Start Screen
func _show_start_screen():
	_reset_ui()
	modal_blocker.visible = true
	start_game_board.visible = true
	start_button.visible = true

	start_button.focus_mode = Control.FOCUS_NONE
	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()

	print("Start screen shown.")

# Utility: Show Times Up Screen
func _show_times_up_screen():
	_reset_ui()
	modal_blocker.visible = true
	times_up_board.visible = true
	times_up_button.visible = true

	times_up_button.focus_mode = Control.FOCUS_NONE
	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_get_focus_owner().release_focus()

	print("Times up screen shown.")

# Utility: Hide All Modals
func _hide_all_modals():
	_reset_ui()
	print("All modals hidden.")
