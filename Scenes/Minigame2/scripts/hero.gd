extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
var gravity: float = 800.0

@onready var instruction_label = $"../UI/InstructionLabel"
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
@export var tile_size := 16   # grid size, make sure this matches the tiles

#-------------------plant variables
@export var seed_scene: PackedScene

#-------------------cover dirt clumps
@export var covered_clump_scene: PackedScene

# Add a boolean to track if an action is in progress
var is_performing_action := false


func _ready():
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
		# This block replaces the separate "if" statements for dig and plant.
		# It ensures only the correct action can happen in each phase.
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
				# We leave this empty because of jump-on-seed
				# mechanic is handled by the seed itself, not a button press.
				pass
			
		move_and_slide()

#---------------seed

func cover_seed() -> bool:
	# 1. Find a planted seed at the player's current tile.
	var player_tile = _to_tile_coords(global_position)
	var seed_to_cover = null

	# Loop through all the 'seeds' in your scene.
	for seed in get_tree().get_nodes_in_group("seeds"):
		var seed_tile = _to_tile_coords(seed.global_position)
		if seed_tile == player_tile:
			seed_to_cover = seed
			break # Found the seed, stop searching

	# 2. If a seed is found, tell it to cover itself.
	if seed_to_cover:
		# The seed itself will handle its replacement.
		seed_to_cover.cover() # <-- We will create this function on the seed

		# 3. Update the counter and check for phase change.
		seeds_covered += 1
		update_counter()
		
		print("Covered seed:", seeds_covered, "/", holes_needed)
		
		if seeds_covered >= holes_needed:
			current_phase = Phase.DONE
			update_counter()
			print("Step 3 complete! All done!")
		
		return true
	else:
		print("No seed to cover at this location")
		return false


#-------------------Helpers for grid snapping
func _to_tile_coords(pos: Vector2) -> Vector2i:
	return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))

func _from_tile_coords(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size, tile.y * tile_size)


#-------------------Dig logic
func spawn_dirt() -> bool: # Add "-> bool" to indicate it returns a boolean
	if current_phase != Phase.DIG:
		print("Can't dig, not in DIG phase")
		return false # <-- Add this

	if not dirt_scene:
		return false # <-- Add this

	# Snap to grid
	var tile_coords = _to_tile_coords(dig_spawn.global_position)
	var spawn_pos = _from_tile_coords(tile_coords)

	# Check if a hole already exists in this tile OR 1 tile away (left/right)
	for dirt in get_tree().get_nodes_in_group("dirt"):
		var dirt_tile = _to_tile_coords(dirt.global_position)
		
		# block same tile
		if dirt_tile == tile_coords:
			print("Hole already here")
			return false # <-- Add this
		
		# block left/right neighbor tiles
		if dirt_tile.x == tile_coords.x - 1 and dirt_tile.y == tile_coords.y:
			print("Too close (left)")
			return false # <-- Add this
		if dirt_tile.x == tile_coords.x + 1 and dirt_tile.y == tile_coords.y:
			print("Too close (right)")
			return false # <-- Add this

	# If we get here, it's valid → spawn dirt
	var new_dirt = dirt_scene.instantiate()
	new_dirt.global_position = spawn_pos
	get_tree().current_scene.add_child(new_dirt)
	new_dirt.add_to_group("dirt")

	$dig_sound.play()

	holes_dug += 1
	update_counter()

	print("Dug hole:", holes_dug, "/", holes_needed)

	if holes_dug >= holes_needed:
		current_phase = Phase.PLANT
		update_counter()
		print("Step 1 complete! Move to PLANT phase.")
	
	return true # <-- Add this for a successful dig

func _on_animated_sprite_2d_animation_finished():
	# This checks if the finished animation was EITHER "dig" OR "plant"
	if animated_sprite.animation == "dig" or animated_sprite.animation == "plant":
		animated_sprite.play("idle")
		is_performing_action = false # This lets the player move again

#-------------------plant logic
func plant_seed() -> bool:
	# 1. Check if the game is in the correct phase.
	if current_phase != Phase.PLANT:
		print("Can't plant, not in PLANT phase")
		return false

	# 2. Find a dug hole at the player's action point.
	# We use dig_spawn.global_position to be consistent with digging.
	var target_tile = _to_tile_coords(dig_spawn.global_position) # <-- THE CHANGE IS HERE
	var hole_to_plant = null
	
	# Loop through all the 'dirt' nodes in your scene.
	for dirt in get_tree().get_nodes_in_group("dirt"):
		var dirt_tile = _to_tile_coords(dirt.global_position)
		if dirt_tile == target_tile:
			hole_to_plant = dirt
			break # Found the hole, stop searching

	# 3. If a hole is found, plant the seed and remove the hole.
	if hole_to_plant:
		$plant_sound.play()
		
		# Instantiate a new seed scene.
		var new_seed = seed_scene.instantiate()
		new_seed.global_position = hole_to_plant.global_position
		get_tree().current_scene.add_child(new_seed)
		
		# Pass the covered clump scene reference to the new seed
		new_seed.set_covered_clump_scene(covered_clump_scene)
		
		# IMPORTANT: This is the line that removes the dirt clump.
		hole_to_plant.queue_free()
		
		# Update the counter and check for phase change.
		seeds_planted += 1
		update_counter()
		
		print("Planted seed:", seeds_planted, "/", holes_needed)
		
		if seeds_planted >= holes_needed:
			current_phase = Phase.COVER
			update_counter()
		return true
	else:
		print("No hole to plant a seed in at this location")
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
			counter_label.text = "All steps complete!"
	update_instructions()
			
			
# Add this new function to hero.gd
func update_instructions():
	match current_phase:
		Phase.DIG:
			instruction_label.text = "Press 'Q' or 'right click' to dig 10 holes!"
		Phase.PLANT:
			instruction_label.text = "Stand on a hole and press 'E' or 'left click' to plant a seed!"
		Phase.COVER:
			instruction_label.text = "Now, press 'space' to jump! jump 2 times on the seeds to cover them up!"
		Phase.DONE:
			instruction_label.text = "Great job! You're an expert gardener! 🌱"
