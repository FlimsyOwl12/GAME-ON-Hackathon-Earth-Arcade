extends Node2D

@onready var dialogue_label: RichTextLabel = $DialogueLabel3
@onready var earth: Sprite2D = $Earth1
signal dialogue_finished
var dialogues := [
"Hello again!
- <Leftclick to Continue>",
"How was your second task?
- <Leftclick to Continue>",
"Hmm-? Looking at you're clothes they're quite dirty"
]

var current_index := 0

func _ready() -> void:
	dialogue_label.bbcode_text = dialogues[current_index]
	earth.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_next_line()

func show_next_line() -> void:
	current_index += 1
	if current_index < dialogues.size():
		dialogue_label.bbcode_text = dialogues[current_index]
	else:
		print("Dialogue finished!")
		emit_signal("dialogue_finished")
	if current_index == 3:
		earth.visible = true
