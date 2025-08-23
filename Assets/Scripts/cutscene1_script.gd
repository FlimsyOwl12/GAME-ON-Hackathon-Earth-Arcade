extends Node2D

@onready var anim_player = $FadeIn/Animation   # <-- point to AnimationPlayer

func _ready():
	if anim_player:
		print("Found AnimationPlayer")
		anim_player.play("transition")   # make sure the animation inside is also named "FadeIn"
	else:
		print("AnimationPlayer not found!")
