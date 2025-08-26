extends Sprite2D

@export var rotation_speed: float = 5.0

func _process(delta):
	rotation_degrees += rotation_speed * delta
