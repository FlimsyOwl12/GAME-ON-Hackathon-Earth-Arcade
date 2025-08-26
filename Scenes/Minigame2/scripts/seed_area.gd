extends Area2D

# How many jumps needed to cover the seed
@export var jumps_needed := 2
var jumps_on_seed := 0

# This scene will replace the seed when it's covered
var covered_clump_scene: PackedScene

@onready var jump_timer = $JumpTimer

# This function runs when the player's body enters the seed's area
func _on_body_entered(body: Node):
	# Check if the body is the player and the game is in the right phase
	if (body.name == "Player" or body.name == "player") and body.current_phase == body.Phase.COVER:
		
		# Check if the player is landing on the seed
		if body.velocity.y > 0 and jump_timer.is_stopped():
			
			# Safely find and play the sound effect
			var jump_sound_node = body.get_node_or_null("jump_sound")
			if jump_sound_node:
				jump_sound_node.play()

			# Update the jump counter and start the cooldown timer
			jumps_on_seed += 1
			jump_timer.start()

			# If enough jumps are registered, cover the seed
			if jumps_on_seed >= jumps_needed:
				cover_the_seed(body)

# handles replacing the seed with a covered clump
func cover_the_seed(player):
	if not covered_clump_scene:
		print("Error: No covered_clump_scene was set!")
		return
		
	print("Seed covered!")
	
	# Update the player's score
	player.seeds_covered += 1
	player.update_counter()
	
	# Create the new covered clump
	var new_clump = covered_clump_scene.instantiate()
	new_clump.global_position = self.global_position
	get_tree().current_scene.add_child.call_deferred(new_clump)
	
	# Check if the player has won
	if player.seeds_covered >= player.holes_needed:
		player.current_phase = player.Phase.DONE
		player.update_counter()
	
	# Remove the seed from the game
	call_deferred("queue_free")


# allows the player to tell the seed what scene to use for the clump
func set_covered_clump_scene(clump_scene: PackedScene):
	self.covered_clump_scene = clump_scene
