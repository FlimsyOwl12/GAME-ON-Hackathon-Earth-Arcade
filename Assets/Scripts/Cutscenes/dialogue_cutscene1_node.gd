extends Node2D

@onready var dialogue_label: RichTextLabel = $DialogueLabel1
@onready var earth: Sprite2D = $Earth1
signal dialogue_finished
var dialogues := [
	"Who goes there?
	- <Left Click to Continue>",
	"Oh it's another human, seemed surprised to see a talking cat? 😅
	- <Left Click to Continue>",
	"Don't be afraid i won't bite, 😄 
	- <Left Click to Continue>",
	"I'm Mawkie, the cat guide
	- <Left Click to Continue>",
	"What's a cat guide you say?
	- <Left Click to Continue>",
	"Well I'm here to guide you on how to take care of the environment of course
	- <Left Click to Continue>",
	"You asked why do you need to take care of our environment?
	- <Left Click to Continue>",
	"Well... look at this
	- <Left Click to Continue>",
	"Look at how the state of the earth looks like right now... trash and polutions is rampant nowadays
	- <Left Click to Continue>",
	"I feel sad to see how mother earth is experiencing right now, that is why you're here!
	- <Left Click to Continue>",
	"You seemed confused?
	- <Left Click to Continue>",
	"You shouldn't be confused at all! Since you're here we can save the world one step at a time
	- <Left Click to Continue>",
	"Let's start on picking up the trash, pretty simple task and straightforward to understand
	- <Left Click to Continue>",
	"I hope you're ready for this task on hand, a task to save the world! Isn't it exciting?
	- <Left Click to Continue>",
	"You sure look excited of course! Now about picking up the trash ill guide how you do it
	- <Left Click to Continue>",
	"The objective on your first mission again is to pick up the trash, you throw the trash towards
	the trashbins
	- <Left Click to Continue>",
	"Are you ready to save the world!
	- <Left Click to Continue>", 
	"I wish you luck on the first task on hand
	- <Left Click to Continue>",
	"I'll meet you soon, take care, have fun, and also remember protect the environment!
	- <Left Click to Enter Minigame 1>",
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
	if current_index == 8:
		earth.visible = true
