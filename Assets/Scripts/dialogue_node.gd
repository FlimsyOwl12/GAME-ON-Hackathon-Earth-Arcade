extends Node2D

@onready var dialogue_label: RichTextLabel = $DialogueLabel

var dialogues := [
	"Who goes there?",
	"Oh it's another human, seemed surprised to see a talking cat? 😅",
	"Don't be afraid i won't bite, 😄 ",
	"I'm Meowki, the cat guide",
	"What's a cat guide you say?",
	"Well I'm here to guide you on how to take care of the environment of course"
]

var current_index := 0

func _ready() -> void:
	dialogue_label.bbcode_text = dialogues[current_index]

# 👇 goes here (same level as _ready)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_next_line()

func show_next_line() -> void:
	current_index += 1
	if current_index < dialogues.size():
		dialogue_label.bbcode_text = dialogues[current_index]
	else:
		print("Dialogue finished!")
