extends Node2D

@onready var dialogue_label: RichTextLabel = $DialogueLabel2
@onready var earth: Sprite2D = $Earth1
signal dialogue_finished
var dialogues := [
"Welcome back, how was your first task?
- <Leftclick to Continue>",
"Oh you look to have done a great job on picking up those trash
- <Leftclick to Continue>",
"With you're effort you helped cleaned up the world a tad bit
- <Leftclick to Continue>",
"WAIT! LOOK AT IT
- <Leftclick to Continue>",
"THE EARTH IS IMPROVING!!!
- <Leftclick to Continue>",
"Great job!!! If you keep doing this we might actually heal the world!
- <Leftclick to Continue>",
"How about it, i shouldn't let you stay here and waste time let's come on down and help the earth once more!
- <Leftclick to Continue>",
"Now the next task should be straightforward again, let me grab my notes.... Ahh!
- <Leftclick to Continue>",
"There it is... So you're next task is to actually plant some more trees
- <Leftclick to Continue>",
"Sounds simple enough so lets head straight to planting!
- <Leftclick to Continue>",
"Goodluck!!! I'll see you soon
- <Leftclick to enter Minigame 2>"
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
