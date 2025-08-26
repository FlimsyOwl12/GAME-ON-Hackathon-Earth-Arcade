extends Sprite2D

var rotation_speed := 10.0
var accumulated_rotation := 0.0

var earth_textures := []
var current_texture_index := 0
var tween  # Let Godot infer SceneTreeTween

var pingpong_direction := 1  # +1 for forward, -1 for backward

func _ready():
	earth_textures = [
		load("res://Assets/PixelArtAssets/MainMenu Assets/Earth1.png"),
		load("res://Assets/PixelArtAssets/MainMenu Assets/Earth2.png"),
		load("res://Assets/PixelArtAssets/MainMenu Assets/Earth3.png")
	]

	texture = earth_textures[current_texture_index]
	centered = true
	modulate.a = 1.0

func _process(delta):
	rotation_degrees += rotation_speed * delta
	accumulated_rotation += rotation_speed * delta

	if accumulated_rotation >= 60.0:
		accumulated_rotation = 0.0

		tween = get_tree().create_tween()

		tween.tween_property(self, "modulate:a", 1.0, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(Callable(self, "_switch_texture"))
		tween.tween_property(self, "modulate:a", 1.0, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _switch_texture():
	# Update index based on direction
	current_texture_index += pingpong_direction

	# Reverse direction at bounds
	if current_texture_index >= 2:
		current_texture_index = 2
		pingpong_direction = -1
	elif current_texture_index <= 0:
		current_texture_index = 0
		pingpong_direction = 1

	texture = earth_textures[current_texture_index]
