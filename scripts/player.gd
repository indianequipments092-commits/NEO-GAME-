extends CharacterBody2D

## Core player controller and Phase 3 combat controller.
const ENERGY_PROJECTILE := preload("res://scenes/energy_projectile.tscn")

@export var move_speed: float = 360.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var fire_interval: float = 0.22

var last_direction := Vector2.UP
var fire_cooldown := 0.0
var projectiles_fired := 0

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	var rate := acceleration if input_direction != Vector2.ZERO else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)

	if input_direction != Vector2.ZERO:
		last_direction = input_direction.normalized()

	move_and_slide()

	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
		fire_energy()

func fire_energy() -> void:
	fire_cooldown = fire_interval
	var projectile := ENERGY_PROJECTILE.instantiate()
	projectile.setup(global_position + last_direction * 30.0, last_direction)
	get_tree().current_scene.add_child(projectile)
	projectiles_fired += 1
	var combat_label := get_tree().current_scene.get_node_or_null("HUD/CombatLabel")
	if combat_label:
		combat_label.text = "ENERGY  •  %03d" % projectiles_fired
