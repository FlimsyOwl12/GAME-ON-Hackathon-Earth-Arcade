extends Node2D

@onready var music_player = $AudioStreamPlayer2D

@onready var dialogue_node = $DialogueNode1
var target_scene := "res://Scenes/Minigame1/Minigame1.tscn"
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

func _on_dialogue_finished() -> void:
	if is_transitioning:
		return
	
	var music_tween := create_tween()
	music_tween.set_trans(Tween.TRANS_LINEAR)
	music_tween.set_ease(Tween.EASE_IN_OUT)
	music_tween.tween_property(music_player, "volume_db", -80, 5.0)
		
	is_transitioning = true
	print("Dialogue finished — fading out music and transitioning scene.")
	
	# Proceed with scene transition
	if FadeManager:
		FadeManager.fade_and_change_scene(target_scene)
	else:
		print("FadeManager not found — fallback to direct scene change.")
		get_tree().change_scene_to_file(target_scene)
