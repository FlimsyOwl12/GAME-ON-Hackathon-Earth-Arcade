extends Node2D

@onready var anim_player_in = $FadeIn/AnimationPlayer 
@onready var anim_player_out = $FadeOut/AnimationPlayer
@onready var dialogue_node = $DialogueNode2

func _ready():
	if anim_player_in:
		print("Found AnimationPlayer")
		anim_player_in.play("transition")
	else:
		print("AnimationPlayer not found!") #Debug Print
	if dialogue_node:
		dialogue_node.dialogue_finished.connect(_on_dialogue_finished)
func _on_dialogue_finished():
	print("Dialogue finished! Trying FadeOut...")
	if anim_player_out:
		print("Found FadeOut Player, animations:", anim_player_out.get_animation_list())
		anim_player_out.play("transition")	
		
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://Scenes/Minigame1/Minigame1.tscn")
	else:
		print("FadeOut AnimationPlayer not found")
