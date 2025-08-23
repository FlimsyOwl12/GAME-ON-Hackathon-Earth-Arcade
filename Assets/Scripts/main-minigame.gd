extends Node2D

# ------------------- Game State -------------------
var score: int = 0
var current_trash: String = ""
var time_left: float = 180
var cursor_texture = preload("res://Assets/PixelArtAssets/Minigame1 Assets/Cursor-removebg-preview.png")

# ------------------- Nodes -------------------
@onready var timer_label = $TimerLabel
@onready var score_label = $ScoredLabel
@onready var goal_popup = $GoalPopup
@onready var start_button = $StartButton
@onready var continue_button = $TimesUpButton

# ------------------- Signals from child hoops -------------------
func _ready():
	# Make buttons work even when game is paused
	start_button.process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	#CONNECTOR HOOPS
	$Recylable.scored.connect(_on_Hoop_scored)
	$Recylable.wrong_trash.connect(_on_wrong)
	$"Non-Biodegradable".scored.connect(_on_Hoop_scored)
	$"Non-Biodegradable".wrong_trash.connect(_on_wrong)
	$Biodegradable.scored.connect(_on_Hoop_scored)
	$Biodegradable.wrong_trash.connect(_on_wrong)

	#CURSOR_CUSTOM
	Input.set_custom_mouse_cursor(cursor_texture)

	#PAUSE AREA
	get_tree().paused = true


	#Button Visibility
	continue_button.visible = false

# ------------------- Score Handling -------------------
func _on_Hoop_scored():
	score += 1
	score_label.text = "Score: " + str(score)
	goal_popup.text = "Good job! Correct Trashcan"

func _on_wrong():
	score -= 1
	if score < 0:
		score = 0
	score_label.text = "Score: " + str(score)
	goal_popup.text = "Oh no! Wrong Trashcan"

# ------------------- Trash Display -------------------
func update_display_label():
	if $DisplayTrash != null:
		$DisplayTrash.text = current_trash.capitalize()

# ------------------- Timer -------------------
func _process(delta):
	if time_left > 0 and not get_tree().paused:
		time_left -= delta
		if timer_label != null:
			timer_label.text = "Timer: " + str(int(time_left))
	else:
		if not get_tree().paused: # prevent multiple game_over calls
			game_over()

# ------------------- Game Over -------------------
func game_over():
	if timer_label != null:
		timer_label.text = ""
	if goal_popup != null:
		goal_popup.text = ""
	start_button.visible = false   # hide start button
	continue_button.visible = true # show continue button
	get_tree().paused = true

# ------------------- Start Button -------------------
func _on_start_button_pressed():
	# Reset values
	score = 0
	time_left = 180
	score_label.text = "Score: 0"
	timer_label.text = str(int(time_left))
	goal_popup.text = ""

	# Resume game
	get_tree().paused = false
	start_button.visible = false
	continue_button.visible = false

# ------------------- Continue Button -------------------
func _on_continue_button_pressed():
	# Reset timer only, keep the score
	time_left = 60
	timer_label.text = str(int(time_left))
	goal_popup.text = ""

	# Resume game
	get_tree().paused = false
	continue_button.visible = false

func _on_times_up_button_pressed() -> void:
	var new_scene = preload("res://Scenes/cutscenes/cutscene2.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene
