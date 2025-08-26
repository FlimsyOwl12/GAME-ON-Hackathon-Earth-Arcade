extends Area2D

signal scored
signal wrong_trash

@export var accepted_trash: Array[String] = ["apple", "apple2", "paper"]  # multiple trash types

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D:
		if "trash_type" in body:
			if body.linear_velocity.y > 0:
				if body.trash_type in accepted_trash:
					emit_signal("scored")
					print("✅ Correct bin for:", body.trash_type) #Debug
					body.queue_free()
				else:
					emit_signal("wrong_trash")
					print("❌ Wrong bin for:", body.trash_type) #Debug
					body.queue_free()
