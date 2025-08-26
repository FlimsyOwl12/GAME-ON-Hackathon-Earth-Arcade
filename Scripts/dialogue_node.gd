extends Node2D

signal dialogue_finished

@onready var dialogue_label: RichTextLabel = $DialogueLabel

var dialogues := [
	"Who goes there?",
	"Oh it's another human, seemed surprised to see a talking cat? 😅",
	"Don't be afraid I won't bite 😄",
	"I'm Meowki, the cat guide",
	"What's a cat guide you say?",
	"Well I'm here to guide you on how to take care of the environment of course"
]

var current_index := 0

func _ready() -> void:
	print("DialogueNode is ready")
	dialogue_label.bbcode_text = dialogues[current_index]

	# Optional: Make sure label doesn't block input
	dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Left click detected")
		show_next_line()

func show_next_line() -> void:
	current_index += 1
	if current_index < dialogues.size():
		dialogue_label.bbcode_text = dialogues[current_index]
	else:
		print("Dialogue finished!")
		emit_signal("dialogue_finished")
