extends CharacterBody2D

## Core player controller with Phase 3 combat and Phase 4 progression.
const ENERGY_PROJECTILE := preload("res://scenes/energy_projectile.tscn")

@export var move_speed: float = 360.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var fire_interval: float = 0.22
@export var max_health: int = 100
@export var contact_invulnerability: float = 0.8

var last_direction := Vector2.UP
var fire_cooldown := 0.0
var projectiles_fired := 0
var xp := 0
var level := 1
var xp_to_next_level := 100
var upgrade_points := 0
var health := 100
var damage_cooldown := 0.0

func _ready() -> void:
	health = max_health
	_update_health_hud()

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	var rate := acceleration if input_direction != Vector2.ZERO else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)

	if input_direction != Vector2.ZERO:
		last_direction = input_direction.normalized()

	move_and_slide()

	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
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

func collect_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		level += 1
		upgrade_points += 1
		xp_to_next_level = 100 + (level - 1) * 50
	_update_progression_hud()

func take_contact_damage(amount: int) -> void:
	if damage_cooldown > 0.0:
		return
	damage_cooldown = contact_invulnerability
	health = maxi(0, health - amount)
	_update_health_hud()
	if health <= 0:
		get_tree().paused = true
		var game_over := get_tree().current_scene.get_node_or_null("HUD/GameOverLabel")
		if game_over:
			game_over.visible = true

func _update_progression_hud() -> void:
	var scene := get_tree().current_scene
	var level_label := scene.get_node_or_null("HUD/LevelLabel")
	var xp_label := scene.get_node_or_null("HUD/XPLabel")
	if level_label:
		level_label.text = "LV  %02d" % level
	if xp_label:
		xp_label.text = "XP  %03d / %03d" % [xp, xp_to_next_level]

func _update_health_hud() -> void:
	var health_label := get_tree().current_scene.get_node_or_null("HUD/HealthLabel")
	if health_label:
		health_label.text = "HULL  %03d / %03d" % [health, max_health]
