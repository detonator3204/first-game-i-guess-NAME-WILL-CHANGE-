extends Area2D

@export var launch_speed := -450.0
@onready var launch: AudioStreamPlayer2D = $Launch
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = launch_speed
		launch.play()
		anim.play("launch")
