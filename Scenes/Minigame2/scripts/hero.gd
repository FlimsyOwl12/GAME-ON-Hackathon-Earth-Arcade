extends CharacterBody2D

const SPEED := 100.0
const JUMP_VELOCITY := -200.0
var gravity := 800.0

@export var instruction_label: Label
@export var timer_label = Timer
@export var counter_label: Label
@export var holes_needed := 10
@export var dirt_scene: PackedScene
@export var seed_scene: PackedScene
@export var covered_clump_scene: PackedScene
@export var tile_size := 16

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dig_spawn: Node2D = $digSpawnPoint
@onready var times_up_board := get_node("/root/Game/UILayer/TimesUpBoard")
@onready var times_up_button := get_node("/root/Game/UILayer/TimesUpBoard/TextureRect/TimesUpButton")
@onready var modal_blocker := get_node("/root/Game/UILayer/ModalBlocker")

@onready var click_effect := get_node("/root/Game/UILayer/TimesUpBoard/TextureRect/TimesUpButton/TimesUpButtonClickSoundEffect")

enum Phase { DIG, PLANT, COVER, DONE }
var current_phase: Phase = Phase.DIG

var holes_dug: int = 0
var seeds_planted: int = 0
var seeds_covered: int = 0
var is_performing_action: bool = false
var start_time_msec: int = 0

func _ready() -> void:
	if times_up_board == null:
		push_error("times_up_board is null. Check node path.")
	if times_up_button == null:
		push_error("times_up_button is null. Check node path or type mismatch.")


	start_time_msec = Time.get_ticks_msec()
	update_counter()
	update_instructions()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_performing_action:
		handle_movement()
		handle_actions()

	if current_phase != Phase.DONE and start_time_msec != 0:
		update_timer()

		move_and_slide()

func handle_movement() -> void:
	var direction: float = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_actions() -> void:
	match current_phase:
		Phase.DIG:
			if Input.is_action_just_pressed("dig") and is_on_floor():
				if spawn_dirt():
					animated_sprite.play("dig")
					is_performing_action = true
					velocity.x = 0
		Phase.PLANT:
			if Input.is_action_just_pressed("plant") and is_on_floor():
				if plant_seed():
					animated_sprite.play("plant")
					is_performing_action = true
					velocity.x = 0
		Phase.COVER:
			pass

func update_timer() -> void:
	var elapsed: float = (Time.get_ticks_msec() - start_time_msec) / 1000.0
	var time_remaining: float = max(0.0, 101.0 - elapsed)
	timer_label.text = "Time Left: " + str(int(time_remaining))

	if time_remaining <= 0:
		current_phase = Phase.DONE
		update_counter()
		update_instructions()
		show_times_up_ui()

func spawn_dirt() -> bool:
	if current_phase != Phase.DIG or dirt_scene == null:
		return false

	var tile_coords: Vector2i = _to_tile_coords(dig_spawn.global_position)
	var spawn_pos: Vector2 = _from_tile_coords(tile_coords)

	for dirt in get_tree().get_nodes_in_group("dirt"):
		var dirt_tile: Vector2i = _to_tile_coords(dirt.global_position)
		if dirt_tile == tile_coords or (abs(dirt_tile.x - tile_coords.x) == 1 and dirt_tile.y == tile_coords.y):
			return false

	var new_dirt: Node2D = dirt_scene.instantiate()
	new_dirt.global_position = spawn_pos
	get_tree().current_scene.add_child(new_dirt)
	new_dirt.add_to_group("dirt")
	$dig_sound.play()
	holes_dug += 1
	update_counter()

	if holes_dug >= holes_needed:
		current_phase = Phase.PLANT
		update_counter()

	return true

func plant_seed() -> bool:
	if current_phase != Phase.PLANT or seed_scene == null:
		return false

	var target_tile: Vector2i = _to_tile_coords(dig_spawn.global_position)
	var hole: Node2D = null

	for dirt in get_tree().get_nodes_in_group("dirt"):
		if _to_tile_coords(dirt.global_position) == target_tile:
			hole = dirt
			break

	if hole != null:
		$plant_sound.play()
		var seed: Node2D = seed_scene.instantiate()
		seed.global_position = hole.global_position
		get_tree().current_scene.add_child(seed)
		seed.set_covered_clump_scene(covered_clump_scene)
		hole.queue_free()
		seeds_planted += 1
		update_counter()

		if seeds_planted >= holes_needed:
			current_phase = Phase.COVER
			update_counter()

		return true

	return false

func cover_seed() -> bool:
	var player_tile: Vector2i = _to_tile_coords(global_position)
	for seed in get_tree().get_nodes_in_group("seeds"):
		if _to_tile_coords(seed.global_position) == player_tile:
			seed.cover()
			seeds_covered += 1
			update_counter()
			if seeds_covered >= holes_needed:
				current_phase = Phase.DONE
				update_counter()
			return true
	return false
	
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation in ["dig", "plant"]:
		animated_sprite.play("idle")
		is_performing_action = false

func update_counter() -> void:
	match current_phase:
		Phase.DIG:
			counter_label.text = str(holes_dug) + " / " + str(holes_needed) + " Holes Dug"
		Phase.PLANT:
			counter_label.text = str(seeds_planted) + " / " + str(holes_needed) + " Seeds Planted"
		Phase.COVER:
			counter_label.text = str(seeds_covered) + " / " + str(holes_needed) + " Holes Covered"
		Phase.DONE:
			if start_time_msec != 0:
				var time_taken: float = (Time.get_ticks_msec() - start_time_msec) / 1000.0
				var final_score: int = max(0, 101 - time_taken)
				counter_label.text = "Final Score: " + str(final_score)					
				
				
				start_time_msec = 0

	update_instructions()
	

func update_instructions() -> void:
	match current_phase:
		Phase.DIG:
			instruction_label.text = "Press 'Q' or 'left click' to dig 10 holes!"
		Phase.PLANT:
			instruction_label.text = "Stand on a hole and press 'E' or 'left click' to plant a seed!"
		Phase.COVER:
			instruction_label.text = "Now, jump 2 times on the seeds to cover them up!"
		Phase.DONE:
			instruction_label.text = "Great job! You're an expert gardener! 🌱"
			show_times_up_ui()
	

func _to_tile_coords(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

func _from_tile_coords(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)
		
func show_times_up_ui() -> void:
	times_up_board.visible = true
	modal_blocker.visible = true
	times_up_board.modulate = Color.WHITE
	times_up_board.z_index = 100

	if times_up_board.has_node("Label"):
		var label := times_up_board.get_node("Label") as Label
		if label != null:
			label.text = "Time's Up!"

	if times_up_button != null:
		times_up_button.visible = true
		times_up_button.process_mode = Node.PROCESS_MODE_ALWAYS
		times_up_button.focus_mode = Control.FOCUS_NONE

	Global.lock_input()
	set_physics_process(false)
	set_process_input(false)
	Input.set_custom_mouse_cursor(null)
	AudioManager.set_music_volume(0, 2.0)

func _on_times_up_button_pressed() -> void:
	print("Button clicked — transitioning scene")
	if click_effect != null:
		click_effect.play()

	await get_tree().create_timer(0.3).timeout

	FadeManager.fade_and_change_scene("res://Scenes/cutscenes/cutscene3.tscn")
