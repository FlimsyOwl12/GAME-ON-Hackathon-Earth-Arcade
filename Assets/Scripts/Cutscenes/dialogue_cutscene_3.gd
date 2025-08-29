extends Node2D

@onready var dialogue_label: RichTextLabel = $DialogueLabel3
@onready var earth: Sprite2D = $Earth1
@onready var usernameblock: Node = $UsernameBlock          # Control is ideal here
@onready var username_input: LineEdit = $UsernameBlock/LineEdit

signal dialogue_finished

var dialogues := [
	"Hello again!\n- <Leftclick to Continue>",
	"How was your second task?\n- <Leftclick to Continue>",
	"Hmm-? Looking at your clothes they're quite dirty\n- <Leftclick to Continue>",
	"Don't worry after all you did a great job for sure, lets see if our tree planting did a great help on mother earth\n- <Leftclick to Continue>",
	"!!!\n- <Leftclick to Continue>",
	"YOU DID IT AGAIN! I'm so astonished this actions you took significantly helped the world\n- <Leftclick to Continue>",
	"Keep it up, I'm sure we can further help our environment\n- <Leftclick to Continue>",
	"Let me check my notes if there are more things we can do\n- <Leftclick to Continue>",
	"Hmmm looks like the notes here said more to come\n- <Leftclick to Continue>",
	"Awee... i guess that's it? Well lets wait for my other notes to arrive\n- <Leftclick to Continue>",
	"When?\n- <Leftclick to Continue>",
	"Who knows when, I still need to rummage the piles of notes and books if i did just misplace them\n- <Leftclick to Continue>",
	"Don't worry tho, what you did so far helped a lot\n- <Leftclick to Continue>",
	"For that! I'll record them on my ledger of people who helped the world\n- <Leftclick to Continue>",
	"AH nevermind till we meet again!\n- <Leftclick to Continue>",
]

var current_index := 0

func _ready() -> void:
	dialogue_label.bbcode_text = dialogues[current_index]
	earth.visible = false
	usernameblock.visible = false

	# ✅ Correct constant usage
	usernameblock.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	username_input.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	username_input.text_submitted.connect(_on_username_submitted)

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:   # prevent skipping while paused
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_next_line()

func show_next_line() -> void:
	current_index += 1
	if current_index < dialogues.size():
		dialogue_label.bbcode_text = dialogues[current_index]
	else:
		print("Dialogue finished!")
		emit_signal("dialogue_finished")

	if current_index == 4:
		earth.visible = true

	 # input works because process_mode = WHEN_PAUSED

func _on_username_submitted(text: String) -> void:
	print("Username entered: ", text)
	get_tree().paused = false
	usernameblock.visible = false
	show_next_line()
