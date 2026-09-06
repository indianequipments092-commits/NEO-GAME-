extends CharacterBody2D

## Core player controller with combat, progression, modules and mobile-compatible input actions.
const ENERGY_PROJECTILE := preload("res://scenes/energy_projectile.tscn")
const DRONE := preload("res://scenes/drone.tscn")

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
var engine_module_level := 0
var core_module_level := 0
var drone_module_level := 0
var drone_instance: Node2D

func _ready() -> void:
	health = max_health
	_update_health_hud()
	_update_module_hud()

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * (move_speed + engine_module_level * 25.0)
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
	fire_cooldown = maxf(0.08, fire_interval - core_module_level * 0.02)
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
	_update_module_hud()

func take_contact_damage(amount: int) -> void:
	if damage_cooldown > 0.0 or health <= 0:
		return
	damage_cooldown = contact_invulnerability
	health = maxi(0, health - amount)
	_update_health_hud()
	if health <= 0:
		var scene := get_tree().current_scene
		if scene.has_method("claim_run_reward"):
			scene.claim_run_reward()
		var game_over := scene.get_node_or_null("HUD/GameOverLabel")
		if game_over:
			game_over.text = "RUN ENDED"
			game_over.visible = true
		var restart := scene.get_node_or_null("HUD/RestartButton")
		if restart:
			restart.visible = true
		get_tree().paused = true

func install_module(module_name: String) -> bool:
	if upgrade_points <= 0:
		return false
	match module_name:
		"engine":
			engine_module_level += 1
		"core":
			core_module_level += 1
		"drone":
			drone_module_level += 1
			if not is_instance_valid(drone_instance):
				drone_instance = DRONE.instantiate()
				get_tree().current_scene.add_child(drone_instance)
		_:
			return false
	upgrade_points -= 1
	_update_module_hud()
	return true

func drone_support_pulse() -> void:
	var label := get_tree().current_scene.get_node_or_null("HUD/ModuleLabel")
	if label:
		label.text = "MODULES  E:%d C:%d D:%d  •  DRONE PULSE" % [engine_module_level, core_module_level, drone_module_level]

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

func _update_module_hud() -> void:
	var label := get_tree().current_scene.get_node_or_null("HUD/ModuleLabel")
	if label:
		label.text = "MODULES  E:%d C:%d D:%d  •  POINTS:%d" % [engine_module_level, core_module_level, drone_module_level, upgrade_points]
