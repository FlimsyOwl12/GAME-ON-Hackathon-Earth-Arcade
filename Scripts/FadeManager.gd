extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var fade_rect: ColorRect = $ColorRect  # Assuming your fade overlay is a ColorRect
var _target_scene: String = ""

func _ready() -> void:
	# Ensure the fade overlay doesn't block input
	layer = 100
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

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

func fade_out_only(target_scene: String) -> void:
	_target_scene = target_scene
	if not anim_player.is_connected("animation_finished", Callable(self, "_on_fade_out_only_finished")):
		anim_player.animation_finished.connect(_on_fade_out_only_finished)
	anim_player.play("FadeOut")

func _on_fade_out_only_finished(anim_name: String) -> void:
	if anim_name == "FadeOut" and _target_scene != "":
		get_tree().change_scene_to_file(_target_scene)
		_target_scene = ""
		anim_player.animation_finished.disconnect(_on_fade_out_only_finished)
		print("Scene changed after fade-out — no fade-in triggered.")
