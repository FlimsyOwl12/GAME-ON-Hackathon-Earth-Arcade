extends Node2D

@onready var music_player = $AudioStreamPlayer2D

@onready var dialogue_node = $DialogueNode3
var target_scene := "res://Scenes/MainMenu/MainMenu.tscn"
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

	is_transitioning = true
	print("Dialogue finished — fading out music and transitioning scene.")

	# Fade out music smoothly with await
	if music_player and music_player.playing:
		await _fade_out_music()
	else:
		print("Music player not active — skipping music fade.")

	# Trigger visual fade-out only
	if FadeManager:
		FadeManager.fade_out_only(target_scene)
	else:
		print("FadeManager not found — fallback to direct scene change.")
		get_tree().change_scene_to_file(target_scene)
		
func _fade_out_music() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(music_player, "volume_db", -80, 1.0)
	await tween.finished
	print("Music fade-out completed.")
