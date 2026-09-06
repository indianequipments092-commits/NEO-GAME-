extends CharacterBody2D

## Core player controller for NEON SPACE SURVIVAL.
@export var move_speed: float = 360.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	var rate := acceleration if input_direction != Vector2.ZERO else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
