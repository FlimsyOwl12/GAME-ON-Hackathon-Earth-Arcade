extends Node2D

# Game State
var score: int = 0
var current_trash: String = ""
var time_left: float
var cursor_texture = preload("res://Assets/PixelArtAssets/Minigame1 Assets/Cursor-removebg-preview.png")

# Audio Stream
var click_stream = preload("res://Assets/SoundEffects/CLICKMenu.mp3")

# Nodes
@onready var timer_label = $TimerLabel
@onready var score_label = $ScoreLabel
@onready var goal_popup = $GoalPopup
@onready var start_button = $StartGameBoard/MarginContainer/TextureRect/StartGameButton
@onready var times_up_button = $TimesUpBoard/MarginContainer/TextureRect/TimesUpButton
@onready var modal_blocker = $ModalBlocker
@onready var start_game_board = $StartGameBoard
@onready var times_up_board = $TimesUpBoard
@onready var click_start_sfx_player = $StartGameBoard/MarginContainer/TextureRect/StartGameButton/StartGameButtonClickSoundEffect
@onready var click_times_up_sfx_player = $TimesUpBoard/MarginContainer/TextureRect/TimesUpButton/TimesUpButtonClickSoundEffect

# Signals from child hoops
func _ready():
	click_start_sfx_player.stream = click_stream
	click_times_up_sfx_player.stream = click_stream

	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	times_up_button.process_mode = Node.PROCESS_MODE_ALWAYS

	$Recylable.scored.connect(_on_Hoop_scored)
	$Recylable.wrong_trash.connect(_on_wrong)
	$"Non-Biodegradable".scored.connect(_on_Hoop_scored)
	$"Non-Biodegradable".wrong_trash.connect(_on_wrong)
	$Biodegradable.scored.connect(_on_Hoop_scored)
	$Biodegradable.wrong_trash.connect(_on_wrong)

	Input.set_custom_mouse_cursor(cursor_texture)

	get_tree().paused = true
	modal_blocker.visible = true
	start_game_board.visible = true
	times_up_board.visible = false
	times_up_button.visible = false

# Score Handling
func _on_Hoop_scored():
	score += 1
	score_label.text = "Score: " + str(score)
	goal_popup.text = "Good job! Correct Trashcan"
	await get_tree().create_timer(1.5).timeout
	goal_popup.text = ""

func _on_wrong():
	score -= 1
	if score < 0:
		score = 0
	score_label.text = "Score: " + str(score)
	goal_popup.text = "Oh no! Wrong Trashcan"
	await get_tree().create_timer(1.5).timeout
	goal_popup.text = ""

# Trash Display
func update_display_label():
	if $DisplayTrash != null:
		$DisplayTrash.text = current_trash.capitalize()

# Timer
func _process(delta):
	if time_left > 0 and not get_tree().paused:
		time_left -= delta
		if timer_label != null:
			timer_label.text = "" + str(int(time_left))
	else:
		if not get_tree().paused:
			game_over()

# Game Over
func game_over():
	timer_label.text = ""
	goal_popup.text = ""
	start_button.visible = false
	times_up_button.visible = true

	modal_blocker.visible = true
	times_up_board.visible = true

	get_tree().paused = true

# Start Button
func _on_start_game_button_pressed():
	click_start_sfx_player.play()

	score = 0
	time_left = 120
	score_label.text = "Score: 0"
	timer_label.text = str(int(time_left))
	goal_popup.text = ""

	get_tree().paused = false

	start_button.visible = false
	start_game_board.visible = false
	modal_blocker.visible = false
	times_up_board.visible = false
	times_up_button.visible = false

# Continue Button (if reused for extra time)
func _on_continue_button_pressed():
	click_times_up_sfx_player.play()

	time_left = 10
	timer_label.text = str(int(time_left))
	goal_popup.text = ""

	get_tree().paused = false
	times_up_button.visible = false
	modal_blocker.visible = false
	times_up_board.visible = false

# Times Up Button (delayed transition)
func _on_times_up_button_pressed():
	click_times_up_sfx_player.play()
	await get_tree().create_timer(0.5).timeout
	var new_scene = preload("res://Scenes/cutscenes/cutscene1.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
