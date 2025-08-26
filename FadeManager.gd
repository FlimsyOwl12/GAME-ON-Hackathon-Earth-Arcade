extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
var _target_scene: String = ""

func fade_and_change_scene(path: String) -> void:
	_target_scene = path
	if not anim_player.is_connected("animation_finished", Callable(self, "_on_anim_finished")):
		anim_player.animation_finished.connect(_on_anim_finished)
	anim_player.play("FadeOut")

func fade_in_only() -> void:
	anim_player.play("FadeIn")

func _on_anim_finished(anim_name: String) -> void:
	if anim_name == "FadeOut" and _target_scene != "":
		get_tree().change_scene_to_file(_target_scene)
		_target_scene = ""
		# run FadeIn after scene load
		call_deferred("_fade_in_next_frame")

func _fade_in_next_frame() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(0.1).timeout  # Give time for scene to initialize
	fade_in_only()
