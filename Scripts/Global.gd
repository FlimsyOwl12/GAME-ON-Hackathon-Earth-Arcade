extends Node

var input_locked := true

func lock_input():
	input_locked = true
	print("Input locked.")

func unlock_input():
	input_locked = false
	print("Input unlocked.")
