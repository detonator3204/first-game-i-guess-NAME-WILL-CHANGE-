extends CharacterBody2D

@onready var animloader: AnimatedSprite2D = $Player
@onready var standbox: Array[CollisionShape2D] = [$PlayerHitbox]
@onready var crouchbox: CollisionShape2D = $CrouchHitbox
@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var jumpsfx: AudioStreamPlayer2D = $JumpSFX
@onready var hit: AudioStreamPlayer2D = $Hit

signal health_changed(new_health: int)

const max_health = 3
var health := max_health
var invincible := false
var hurt := false

const speed = 125
const crouch_speed = 60
const jumpvel = -290

var landing := false


func _ready() -> void:
	animplayer.animation_finished.connect(_on_anim_finished)


func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "recovery":
		landing = false

func take_damage(amount: int = 1, hitter_velocity: Vector2 = Vector2.ZERO) -> void:
	if invincible:
		return
	health -= amount
	health_changed.emit(health)
	if health <= 0:
		die()
		return

	invincible = true
	hurt = true

	if velocity.length() > 20.0:
		velocity = -velocity
	elif hitter_velocity.length() > 20.0:
		velocity = hitter_velocity
	else:
		velocity = Vector2(-150.0 if not animloader.flip_h else 150.0, -150.0)

	velocity = velocity.limit_length(250.0)
	animloader.play("hit")
	hit.play()
	animplayer.play("recovery")

	await get_tree().create_timer(0.3).timeout
	hurt = false

	var tween := create_tween().set_loops(5)
	tween.tween_property(animloader, "modulate:a", 0.3, 0.1)
	tween.tween_property(animloader, "modulate:a", 1.0, 0.1)
	await tween.finished
	animloader.modulate.a = 1.0
	invincible = false


func die() -> void:
	set_physics_process(false)
	animloader.play("die")
	animplayer.play("recovery")
	hit.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var was_on_floor := is_on_floor()

	if not is_on_floor():
		var g := get_gravity()
		if Input.is_action_pressed("crouch"):
			g *= 2
		velocity += g * delta
	if hurt:
		move_and_slide()
		return

	var direction := Input.get_axis("left", "right")
	var crouching := Input.is_action_pressed("crouch") and is_on_floor()

	if crouching and Input.is_action_just_pressed("crouch"):
		animplayer.play("recovery")

	for hitbox in standbox:
		hitbox.set_deferred("disabled", crouching)
	crouchbox.set_deferred("disabled", not crouching)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not crouching:
		velocity.y = jumpvel
		animplayer.play("jump")
		jumpsfx.play()


	var current_speed := crouch_speed if crouching else speed
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, speed)
	else:
		velocity.x = direction * current_speed
		animloader.flip_h = direction < 0

	if not is_on_floor():
		landing = false
		animloader.play("jump" if velocity.y < 0 else "fall")
		if velocity.y > 0:
			animplayer.play("fall")
	elif crouching:
		animloader.play("crouchwalk" if direction != 0 else "crouch")
	elif direction != 0:
		animloader.play("walk")
	else:
		animloader.play("idle")

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		landing = true
		animplayer.play("recovery")
