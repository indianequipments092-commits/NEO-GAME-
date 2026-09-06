extends CharacterBody2D

## Phase 12 — premium ship, 10-second radial ability, health/death state.
const ENERGY_PROJECTILE := preload("res://scenes/energy_projectile.tscn")
const DRONE := preload("res://scenes/drone.tscn")

@export var move_speed: float = 360.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var fire_interval: float = 0.22
@export var max_health: int = 100
@export var contact_invulnerability: float = 0.8
@export var special_cooldown_max: float = 10.0
@export var special_duration: float = 1.8
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.16
@export var dash_cooldown_max: float = 1.2

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
var special_cooldown := 0.0
var special_time_left := 0.0
var dash_time_left := 0.0
var dash_cooldown := 0.0
var dead := false

func _ready() -> void:
	health = max_health
	_update_health_hud()
	_update_module_hud()
	_update_special_hud()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if dead:
		velocity = Vector2.ZERO
		queue_redraw()
		return
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction != Vector2.ZERO:
		last_direction = input_direction.normalized()
	var target_velocity := input_direction * (move_speed + engine_module_level * 25.0)
	var rate := acceleration if input_direction != Vector2.ZERO else friction
	if dash_time_left > 0.0:
		dash_time_left = maxf(0.0, dash_time_left - delta)
		velocity = last_direction * dash_speed
	else:
		velocity = velocity.move_toward(target_velocity, rate * delta)
	move_and_slide()
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	damage_cooldown = maxf(0.0, damage_cooldown - delta)
	special_cooldown = maxf(0.0, special_cooldown - delta)
	dash_cooldown = maxf(0.0, dash_cooldown - delta)
	if special_time_left > 0.0:
		special_time_left = maxf(0.0, special_time_left - delta)
	_update_special_hud()
	if Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
		fire_energy()

func fire_energy() -> void:
	if dead:
		return
	fire_cooldown = maxf(0.08, fire_interval - core_module_level * 0.02)
	var projectile := ENERGY_PROJECTILE.instantiate()
	projectile.setup(global_position + last_direction * 30.0, last_direction)
	get_tree().current_scene.add_child(projectile)
	projectiles_fired += 1
	var combat_label := get_tree().current_scene.get_node_or_null("HUD/StatusPanel/CombatLabel")
	if combat_label:
		combat_label.text = "ENERGY  •  %03d" % projectiles_fired

func activate_special() -> bool:
	if dead or special_cooldown > 0.0:
		return false
	special_cooldown = special_cooldown_max
	special_time_left = special_duration
	var scene := get_tree().current_scene
	var count := 24
	for i in count:
		var angle := TAU * float(i) / float(count)
		var direction := Vector2(cos(angle), sin(angle))
		var projectile := ENERGY_PROJECTILE.instantiate()
		projectile.setup(global_position + direction * 42.0, direction)
		scene.add_child(projectile)
		projectiles_fired += 1
	_update_special_hud()
	queue_redraw()
	return true

func perform_dash() -> bool:
	if dead or dash_cooldown > 0.0:
		return false
	var direction := last_direction
	if direction == Vector2.ZERO:
		direction = Vector2.UP
	last_direction = direction.normalized()
	dash_cooldown = dash_cooldown_max
	dash_time_left = dash_duration
	velocity = last_direction * dash_speed
	queue_redraw()
	return true

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
	if dead or damage_cooldown > 0.0 or health <= 0:
		return
	damage_cooldown = contact_invulnerability
	health = maxi(0, health - amount)
	_update_health_hud()
	queue_redraw()
	if health <= 0:
		_die()

func _die() -> void:
	if dead:
		return
	dead = true
	velocity = Vector2.ZERO
	var scene := get_tree().current_scene
	if scene.has_method("claim_run_reward"):
		scene.claim_run_reward()
	# Game-over UI must be the only touch target after death.
	var mobile_controls := scene.get_node_or_null("MobileControls")
	if mobile_controls:
		mobile_controls.visible = false
		mobile_controls.process_mode = Node.PROCESS_MODE_DISABLED
	var game_over := scene.get_node_or_null("HUD/GameOverPanel")
	if game_over:
		game_over.process_mode = Node.PROCESS_MODE_ALWAYS
		game_over.mouse_filter = Control.MOUSE_FILTER_STOP
		game_over.visible = true
		var label := game_over.get_node_or_null("GameOverLabel")
		if label:
			label.text = "GAME OVER"
		var sub := game_over.get_node_or_null("GameOverSubLabel")
		if sub:
			sub.text = "YOUR SHIP HAS BEEN DESTROYED"
		var restart := game_over.get_node_or_null("RestartButton")
		if restart:
			restart.process_mode = Node.PROCESS_MODE_ALWAYS
			restart.mouse_filter = Control.MOUSE_FILTER_STOP
			restart.visible = true
		var exit := game_over.get_node_or_null("ExitButton")
		if exit:
			exit.process_mode = Node.PROCESS_MODE_ALWAYS
			exit.mouse_filter = Control.MOUSE_FILTER_STOP
			exit.visible = true
	get_tree().paused = true
	queue_redraw()

func install_module(module_name: String) -> bool:
	if upgrade_points <= 0:
		return false
	match module_name:
		"engine": engine_module_level += 1
		"core": core_module_level += 1
		"drone":
			drone_module_level += 1
			if not is_instance_valid(drone_instance):
				drone_instance = DRONE.instantiate()
				get_tree().current_scene.add_child(drone_instance)
		_: return false
	upgrade_points -= 1
	_update_module_hud()
	return true

func drone_support_pulse() -> void:
	var label := get_tree().current_scene.get_node_or_null("HUD/StatusPanel/ModuleLabel")
	if label:
		label.text = "MODULES  E:%d C:%d D:%d  •  DRONE PULSE" % [engine_module_level, core_module_level, drone_module_level]

func _update_progression_hud() -> void:
	var scene := get_tree().current_scene
	var level_label := scene.get_node_or_null("HUD/TopLeft/LevelLabel")
	var xp_label := scene.get_node_or_null("HUD/TopLeft/XPLabel")
	var xp_bar := scene.get_node_or_null("HUD/XPBar")
	if level_label:
		level_label.text = "LV  %02d" % level
	if xp_label:
		xp_label.text = "XP  %03d / %03d" % [xp, xp_to_next_level]
	if xp_bar:
		xp_bar.value = (float(xp) / float(xp_to_next_level)) * 100.0

func _update_health_hud() -> void:
	var scene := get_tree().current_scene
	var health_label := scene.get_node_or_null("HUD/StatusPanel/HealthLabel")
	var health_bar := scene.get_node_or_null("HUD/StatusPanel/HealthBar")
	if health_label:
		health_label.text = "HULL  %03d / %03d" % [health, max_health]
	if health_bar:
		health_bar.value = (float(health) / float(max_health)) * 100.0

func _update_special_hud() -> void:
	var scene := get_tree().current_scene
	var controls := scene.get_node_or_null("MobileControls/Controls")
	if controls and controls.has_method("set_special_cooldown"):
		controls.set_special_cooldown(special_cooldown, special_cooldown_max, special_time_left)

func _update_module_hud() -> void:
	var label := get_tree().current_scene.get_node_or_null("HUD/StatusPanel/ModuleLabel")
	if label:
		label.text = "MODULES E:%d C:%d D:%d  •  POINTS:%d" % [engine_module_level, core_module_level, drone_module_level, upgrade_points]

func _draw() -> void:
	var pulse := 0.85 + sin(Time.get_ticks_msec() * 0.012) * 0.15
	var flame_len := 55.0 * pulse
	for side in [-1.0, 1.0]:
		var base := Vector2(22.0 * side, 22.0)
		var tip := Vector2(22.0 * side, 22.0 + flame_len)
		draw_colored_polygon(PackedVector2Array([base + Vector2(-9, 0), base + Vector2(9, 0), tip + Vector2(0, 8)]), Color(1.0, 0.28, 0.03, 0.92))
		draw_colored_polygon(PackedVector2Array([base + Vector2(-5, 0), base + Vector2(5, 0), tip + Vector2(0, 2)]), Color(1.0, 0.88, 0.25, 0.95))
	if special_time_left > 0.0 and not dead:
		var radius := 62.0 + sin(Time.get_ticks_msec() * 0.018) * 6.0
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(0.35, 0.9, 1.0, 0.9), 6.0, true)
		draw_arc(Vector2.ZERO, radius + 12.0, 0.0, TAU, 96, Color(0.7, 0.15, 1.0, 0.6), 3.0, true)
