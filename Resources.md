# Resources

### Basic Damage Code Applied to any Area2D with a CollisionBox2D as a child node.
------------------------------------------------------
extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1, Vector2.ZERO)

-----------------------------------------------------

### Idea on how to add damage
Maybe make a new variable inside this script, which relays the health, then edit the player script to set a base damage for the player
and add an interaction when every time the function hit is called, it decreases the health variable (Just an idea)

func _hit() -> void:
	player.attack - enemy.health

Basic Idea On What To Do, you can research stuff / or just make a claude account and make it explain it to you, AI is
a really good resource for learning, especially if your new.