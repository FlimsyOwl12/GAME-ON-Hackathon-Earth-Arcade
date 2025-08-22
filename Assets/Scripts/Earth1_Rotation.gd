extends Sprite2D

# Rotation speed in degrees per second
var rotation_speed := 5.0

func _process(delta):
	rotation_degrees += rotation_speed * delta
