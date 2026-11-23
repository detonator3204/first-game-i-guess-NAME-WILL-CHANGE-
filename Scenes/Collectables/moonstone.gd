extends Area2D

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var sound: AudioStreamPlayer2D = $Collection

var collected := false
var value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

signal collect

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	collected = true
	$CollisionShape2D.set_deferred("disabled", true)
	player.play("collect")
	sound.play()
