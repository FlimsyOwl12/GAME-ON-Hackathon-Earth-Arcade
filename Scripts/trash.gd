extends RigidBody2D

@export var lifetime = 5.0
@export var bounce = 0.5

# List of trash types + their textures
@export var trash_types := {
	"apple": "res://Assets/PixelArtAssets/Minigame1 Assets/apple.png",
	"apple2": "res://Assets/PixelArtAssets/Minigame1 Assets/apple2.png",
	"can1": "res://Assets/PixelArtAssets/Minigame1 Assets/can 1.png",
	"can": "res://Assets/PixelArtAssets/Minigame1 Assets/can.png",
	"paper": "res://Assets/PixelArtAssets/Minigame1 Assets/crumpled paper.png",
	"bottle": "res://Assets/PixelArtAssets/Minigame1 Assets/bottle.png",
	"juicecarton": "res://Assets/PixelArtAssets/Minigame1 Assets/JuiceCarton.png"

}

var trash_type: String = ""
var timer = 0.0

func _ready():
	# Physics material
	var mat = PhysicsMaterial.new()
	mat.bounce = bounce
	mat.friction = 0.4
	physics_material_override = mat
	
	# Don't pick random trash here anymore!
	# The trash type will be set externally
	if trash_type != "" and has_node("Sprite2D"):
		$Sprite2D.texture = load(trash_types[trash_type])

func set_trash_type(t_type: String):
	trash_type = t_type
	if has_node("Sprite2D") and trash_types.has(trash_type):
		$Sprite2D.texture = load(trash_types[trash_type])

func _physics_process(delta):
	# Lifetime countdown
	timer += delta
	if timer >= lifetime:
		queue_free()

	# Remove if offscreen
	var viewport_rect = get_viewport_rect()
	if global_position.x < -100 or global_position.x > viewport_rect.size.x + 100 \
	or global_position.y < -100 or global_position.y > viewport_rect.size.y + 100:
		queue_free()
