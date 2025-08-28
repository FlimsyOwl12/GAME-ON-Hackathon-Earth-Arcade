extends Node2D

@onready var dialogue_node = $DialogueNode2
var target_scene := "res://Scenes/Minigame2/scenes/Minigame2.tscn"
var is_transitioning := false

func _ready():
	# Trigger global fade-in if needed
	if FadeManager:
		FadeManager.fade_in_only()
	else:
		print("FadeManager not found — skipping fade-in.")

	# Connect dialogue finished signal
	if dialogue_node:
		dialogue_node.dialogue_finished.connect(_on_dialogue_finished)

func _on_dialogue_finished():
	if is_transitioning:
		return

	is_transitioning = true
	print("Dialogue finished — triggering global fade-out and scene change.")

	if FadeManager:
		FadeManager.fade_and_change_scene(target_scene)
	else:
		print("FadeManager not found — fallback to direct scene change.")
		get_tree().change_scene_to_file(target_scene)
