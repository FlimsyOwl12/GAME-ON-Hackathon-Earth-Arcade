extends Node2D

@onready var dialogue_node = $DialogueNode1


func _ready():
	# Trigger a fade-in at the start of the cutscene
	FadeManager.fade_in_only()

	# Connect dialogue finished signal
	if dialogue_node.has_signal("dialogue_finished"):
		dialogue_node.dialogue_finished.connect(_on_dialogue_finished)
	else:
		print("DialogueNode missing 'dialogue_finished' signal")

func _on_dialogue_finished():
	print("Dialogue finished. Transitioning to Minigame1...")
	FadeManager.fade_and_change_scene("res://Scenes/Minigame1/Minigame1.tscn")
