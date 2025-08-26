extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
var gravity: float = 800.0


@onready var instruction_label = $"../UI/InstructionLabel"
@onready var timer_label = $"../UI/TimerLabel"
@onready var animated_sprite = $AnimatedSprite2D
@export var counter_label: Label

#-------------------game phases
enum Phase { DIG, PLANT, COVER, DONE }
var current_phase = Phase.DIG

#-------------------phase counters
@export var holes_needed := 10
var holes_dug := 0
var seeds_planted := 0
var seeds_covered := 0

#-------------------dig variables
@onready var dig_spawn = $digSpawnPoint
@export var dirt_scene: PackedScene
@export var tile_size := 16    # grid size, make sure this matches the tiles

#-------------------plant variables
@export var seed_scene: PackedScene

#-------------------cover dirt clumps
@export var covered_clump_scene: PackedScene

# Add a boolean to track if an action is in progress
var is_performing_action := false

# --- NEW VARIABLE FOR SCORING ---
var start_time_msec := 0

func _ready():
	# --- START THE TIMER ---
	start_time_msec = Time.get_ticks_msec()
	
	update_counter()
	update_instructions()

#-------------------physics sections
func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Only process movement and input if not performing an action
	if not is_performing_action:
		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Input direction
		var direction := Input.get_axis("move_left", "move_right")

		# Flip sprite
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

		# Animations
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")

		# Apply movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		# --- ACTION LOGIC ---
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
					# --- TIMER UI UPDATE ---
		if current_phase != Phase.DONE and start_time_msec != 0:
			var elapsed_seconds = (Time.get_ticks_msec() - start_time_msec) / 1000.0
			var time_remaining = 101.0 - elapsed_seconds
			
			# Stop the timer from going below zero
			if time_remaining < 0:
				time_remaining = 0
			
			timer_label.text = "Time Left: " + str(int(time_remaining))
			
			# Check if the player has run out of time
			if time_remaining <= 0:
				current_phase = Phase.DONE
				update_counter() # This will trigger the "Final Score" display
				update_instructions()
			
		move_and_slide()


#---------------seed
# Note: The cover_seed function is not used by the jump-on-seed mechanic
# and can be removed if you wish, but it is harmless to keep.
func cover_seed() -> bool:
	var player_tile = _to_tile_coords(global_position)
	var seed_to_cover = null
	for seed in get_tree().get_nodes_in_group("seeds"):
		var seed_tile = _to_tile_coords(seed.global_position)
		if seed_tile == player_tile:
			seed_to_cover = seed
			break
	if seed_to_cover:
		seed_to_cover.cover()
		seeds_covered += 1
		update_counter()
		if seeds_covered >= holes_needed:
			current_phase = Phase.DONE
			update_counter()
		return true
	else:
		return false

#-------------------Helpers for grid snapping
func _to_tile_coords(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

func _from_tile_coords(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)


#-------------------Dig logic
func spawn_dirt() -> bool:
	if current_phase != Phase.DIG:
		return false

	if not dirt_scene:
		return false

	var tile_coords = _to_tile_coords(dig_spawn.global_position)
	var spawn_pos = _from_tile_coords(tile_coords)

	for dirt in get_tree().get_nodes_in_group("dirt"):
		var dirt_tile = _to_tile_coords(dirt.global_position)
		if dirt_tile == tile_coords:
			return false
		if dirt_tile.x == tile_coords.x - 1 and dirt_tile.y == tile_coords.y:
			return false
		if dirt_tile.x == tile_coords.x + 1 and dirt_tile.y == tile_coords.y:
			return false

	var new_dirt = dirt_scene.instantiate()
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

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "dig" or animated_sprite.animation == "plant":
		animated_sprite.play("idle")
		is_performing_action = false

#-------------------plant logic
func plant_seed() -> bool:
	if current_phase != Phase.PLANT:
		return false

	var target_tile = _to_tile_coords(dig_spawn.global_position)
	var hole_to_plant = null
	
	for dirt in get_tree().get_nodes_in_group("dirt"):
		var dirt_tile = _to_tile_coords(dirt.global_position)
		if dirt_tile == target_tile:
			hole_to_plant = dirt
			break

	if hole_to_plant:
		$plant_sound.play()
		var new_seed = seed_scene.instantiate()
		new_seed.global_position = hole_to_plant.global_position
		get_tree().current_scene.add_child(new_seed)
		new_seed.set_covered_clump_scene(covered_clump_scene)
		hole_to_plant.queue_free()
		seeds_planted += 1
		update_counter()
		
		if seeds_planted >= holes_needed:
			current_phase = Phase.COVER
			update_counter()
		return true
	else:
		return false

#-------------------UI update helper
func update_counter():
	match current_phase:
		Phase.DIG:
			counter_label.text = str(holes_dug) + " / " + str(holes_needed) + " Holes Dug"
		Phase.PLANT:
			counter_label.text = str(seeds_planted) + " / " + str(holes_needed) + " Seeds Planted"
		Phase.COVER:
			counter_label.text = str(seeds_covered) + " / " + str(holes_needed) + " Holes Covered"
		Phase.DONE:
			# --- UPDATED SCORING LOGIC ---
			# Only calculate the final score once
			if start_time_msec != 0: 
				# Calculate elapsed time in seconds
				var time_taken_sec = (Time.get_ticks_msec() - start_time_msec) / 1000.0
				
				# Calculate final score (ensuring it can't go below zero)
				var final_score = max(0, 101 - time_taken_sec)
				
				# Display the score as a whole number
				counter_label.text = "Final Score: " + str(int(final_score))
				
				# Set start_time_msec to 0 to prevent this from running again
				start_time_msec = 0

	update_instructions()
			
# Add this new function to hero.gd
func update_instructions():
	match current_phase:
		Phase.DIG:
			instruction_label.text = "Press 'Q' or 'right click' to dig 10 holes!"
		Phase.PLANT:
			instruction_label.text = "Stand on a hole and press 'E' or 'left click' to plant a seed!"
		Phase.COVER:
			instruction_label.text = "Now, jump 2 times on the seeds to cover them up!"
		Phase.DONE:
			instruction_label.text = "Great job! You're an expert gardener! 🌱"
