extends Node2D

@export var bullet_scene = preload("res://Scenes/Minigame1/trash.tscn")
@export var min_speed = 500
@export var max_speed = 1200
@export var max_active_balls = 3
@export var charge_rate = 500  # how fast the charge moves
@export var trash_types = ["apple", "can","paper","can1","apple2","bottle"]

@onready var preview = $ThrowPreview
@onready var spawner = $SpawnerNode
@onready var bar = $CharginBar
@onready var display_label = $DisplayTrash  # Label node
@onready var Body = $Body
@onready var Hand = $Hands

var is_charging = false
var charge_speed = 0
var charge_direction = 1  # 1 = increasing, -1 = decreasing
var active_balls = []
var current_trash: String = ""
var trash_names = {
	"apple": "Half Eaten Apple ",
	"apple2": "Partially Eaten Apple",
	"can": "Crushed Can",
	"can1": "Intact Can",
	"paper": "Crumpled Paper",
	"bottle": "Plastic Bottle",
}

func _ready():
	pick_random_trash()

func _process(delta):
	#Despawn Balls Section
	active_balls = active_balls.filter(func(b): return b != null and is_instance_valid(b))

	# Charge Logic and Animation
	if Input.is_key_pressed(KEY_SPACE) and active_balls.size() < max_active_balls:
		is_charging = true

# ------------------- Animation  -------------------
		charge_speed += charge_rate * delta * charge_direction
		if charge_speed >= max_speed:
			charge_speed = max_speed
			charge_direction = -1
		elif charge_speed <= min_speed:
			charge_speed = min_speed
			charge_direction = 1

		# Switch between idle (0) and ready (1)
		if Body != null and Hand != null:
			if charge_direction > 0:
				Body.frame = 1  # ready
				Hand.frame = 1
			else:
				Body.frame = 0  # idle
				Hand.frame = 0

	else:
		if is_charging:
			#Ball Shoot
			shoot_ball(charge_speed)
			charge_speed = min_speed
			charge_direction = 1
			is_charging = false

			#Asynchronous Firing
			fire_cannon_animation()

	#Charging Bar
	update_charge_bar()

func shoot_ball(speed):
	var ball = bullet_scene.instantiate()
	ball.trash_type = current_trash
	ball.global_position = spawner.global_position
	var direction = (get_global_mouse_position() - ball.global_position).normalized()
	ball.linear_velocity = direction * speed
	get_parent().add_child(ball)
	active_balls.append(ball)
	pick_random_trash()
	print("Threw:", current_trash) #Debug

func update_charge_bar():
	if bar != null and bar is ProgressBar:
		var percent = (charge_speed - min_speed) / (max_speed - min_speed) * 100.0
		bar.value = clamp(percent, 0.0, 100.0)

func pick_random_trash():
	current_trash = trash_types.pick_random()
	update_preview()
	update_display_label()
# ------------------- Preview Placeholder-------------------
func update_preview():
	if preview == null:
		return
	var tex: Texture = null
	match current_trash:
		"apple":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/apple.png")
		"can":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/can.png")
		"paper":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/crumpled paper.png")
		"apple2":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/apple2.png")
		"can1":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/can 1.png")
		"bottle":
			tex = load("res://Assets/PixelArtAssets/Minigame1 Assets/bottle.png")
	if tex != null:
		if preview is Sprite2D:
			preview.texture = tex
		elif preview is TextureRect:
			preview.texture = tex

func update_display_label():
	if display_label != null:
		display_label.text = trash_names.get(current_trash, current_trash)

# Async function for firing animation (Body + Hands)
func fire_cannon_animation() -> void:
	if Body != null:
		Body.frame = 1  # firing frame
	if Hand != null:
		Hand.frame = 2  # firing hand frame
	await get_tree().create_timer(0.1).timeout
	if Body != null:
		Body.frame = 0  # back to idle
	if Hand != null:
		Hand.frame = 0  # back to idle
