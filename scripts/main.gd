extends Node2D

# NEON SPACE SURVIVAL — Phase 12 UI integration.
const XP_ORB := preload("res://scenes/xp_orb.tscn")
const ENEMY := preload("res://scenes/enemy.tscn")
const BOSS := preload("res://scenes/boss.tscn")

var survival_time := 0.0
var xp_spawn_time := 0.0
var enemy_spawn_time := 0.0
var xp_spawn_interval := 1.5
var enemy_spawn_interval := 1.5
var boss_spawned := false
var module_input_cooldown := 0.0
var meta_cores := 0
var juice_time := 0.0
var run_reward_claimed := false
var game_over := false
var _game_over_touch_lock := false
const MAX_ACTIVE_ENEMIES := 24

@onready var timer_label: Label = $HUD/TopLeft/TimerLabel
@onready var player: CharacterBody2D = $Player
@onready var boss_label: Label = $HUD/BossPanel/BossLabel
@onready var boss_bar: ProgressBar = $HUD/BossPanel/BossBar
@onready var xp_bar: ProgressBar = $HUD/XPBar
@onready var economy: Node = $Economy
@onready var credits_label: Label = $HUD/CreditsPanel/CreditsLabel
@onready var game_over_panel: Panel = $HUD/GameOverPanel
@onready var mobile_controls: CanvasLayer = $MobileControls

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	timer_label.text = "SURVIVAL  00:00"
	_update_progression_hud()
	_update_health_hud()
	_update_economy_hud()
	_build_game_over_actions()
	_set_game_over_state(false)

func _input(event: InputEvent) -> void:
	if not game_over or _game_over_touch_lock:
		return
	if event is InputEventScreenTouch and event.pressed:
		var p := event.position
		var restart_rect := Rect2(475, 365, 155, 55)
		var exit_rect := Rect2(650, 365, 155, 55)
		if restart_rect.has_point(p):
			_game_over_touch_lock = true
			restart_run()
			get_viewport().set_input_as_handled()
		elif exit_rect.has_point(p):
			_game_over_touch_lock = true
			exit_to_lobby()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if get_tree().paused or game_over:
		return
	survival_time += delta
	xp_spawn_time += delta
	enemy_spawn_time += delta
	module_input_cooldown = maxf(0.0, module_input_cooldown - delta)
	juice_time += delta
	if xp_spawn_time >= xp_spawn_interval:
		xp_spawn_time = 0.0
		_spawn_xp_orb()
	if enemy_spawn_time >= enemy_spawn_interval:
		enemy_spawn_time = 0.0
		_spawn_enemy()
	if survival_time >= 60.0 and not boss_spawned:
		boss_spawned = true
		_spawn_boss()
	_handle_module_input()
	_update_boss_juice()
	var total_seconds := int(survival_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "SURVIVAL  %02d:%02d" % [minutes, seconds]

func _build_game_over_actions() -> void:
	var panel := game_over_panel
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var sub := panel.get_node_or_null("GameOverSubLabel")
	if sub == null:
		sub = Label.new()
		sub.name = "GameOverSubLabel"
		sub.position = Vector2(25, 108)
		sub.size = Vector2(370, 40)
		sub.add_theme_font_size_override("font_size", 14)
		sub.add_theme_color_override("font_color", Color("ff7088"))
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		panel.add_child(sub)
	sub.text = "YOUR SHIP HAS BEEN DESTROYED"

	var restart := panel.get_node_or_null("RestartButton") as Button
	if restart:
		restart.visible = true
		restart.disabled = false
		restart.mouse_filter = Control.MOUSE_FILTER_STOP
		restart.process_mode = Node.PROCESS_MODE_ALWAYS
		restart.focus_mode = Control.FOCUS_ALL
		restart.position = Vector2(45, 160)
		restart.size = Vector2(155, 55)
		restart.text = "RESTART RUN"
		restart.add_theme_font_size_override("font_size", 16)
	if restart and not restart.pressed.is_connected(restart_run):
		restart.pressed.connect(restart_run)

	var exit := panel.get_node_or_null("ExitButton") as Button
	if exit == null:
		exit = Button.new()
		exit.name = "ExitButton"
		panel.add_child(exit)
	exit.visible = true
	exit.disabled = false
	exit.mouse_filter = Control.MOUSE_FILTER_STOP
	exit.process_mode = Node.PROCESS_MODE_ALWAYS
	exit.focus_mode = Control.FOCUS_ALL
	exit.position = Vector2(220, 160)
	exit.size = Vector2(155, 55)
	exit.text = "EXIT"
	exit.add_theme_font_size_override("font_size", 16)
	exit.add_theme_color_override("font_color", Color("dff8ff"))
	if not exit.pressed.is_connected(exit_to_lobby):
		exit.pressed.connect(exit_to_lobby)

func _set_game_over_state(value: bool) -> void:
	game_over = value
	_game_over_touch_lock = false
	game_over_panel.visible = value
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	if mobile_controls:
		mobile_controls.visible = not value
		mobile_controls.process_mode = Node.PROCESS_MODE_ALWAYS
		var controls := mobile_controls.get_node_or_null("Controls")
		if controls:
			controls.visible = not value
			controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var joystick := mobile_controls.get_node_or_null("FloatingJoystick")
		if joystick:
			joystick.visible = not value
			joystick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if value:
		Input.action_release("fire")
		get_tree().paused = true

func on_player_game_over() -> void:
	if game_over:
		return
	_set_game_over_state(true)

func _handle_module_input() -> void:
	if module_input_cooldown > 0.0 or player.upgrade_points <= 0:
		return
	if Input.is_key_pressed(KEY_1):
		player.install_module("engine")
		module_input_cooldown = 0.25
	elif Input.is_key_pressed(KEY_2):
		player.install_module("core")
		module_input_cooldown = 0.25
	elif Input.is_key_pressed(KEY_3):
		player.install_module("drone")
		module_input_cooldown = 0.25

func _spawn_xp_orb() -> void:
	var orb := XP_ORB.instantiate()
	var margin := 80.0
	orb.position = Vector2(randf_range(margin, 1280.0 - margin), randf_range(margin, 720.0 - margin))
	add_child(orb)

func spawn_enemy_xp(spawn_position: Vector2, value: int) -> void:
	var orb := XP_ORB.instantiate()
	orb.position = spawn_position
	orb.xp_value = value
	add_child(orb)

func _spawn_enemy() -> void:
	var active := 0
	for child in get_children():
		if child.is_in_group("enemies"):
			active += 1
	if active >= MAX_ACTIVE_ENEMIES:
		return
	var enemy := ENEMY.instantiate()
	enemy.name = "Enemy_%03d" % active
	enemy.add_to_group("enemies")
	enemy.position = _random_enemy_spawn_position()
	add_child(enemy)

func _random_enemy_spawn_position() -> Vector2:
	var side := randi() % 4
	match side:
		0: return Vector2(randf_range(90.0, 1190.0), 115.0)
		1: return Vector2(randf_range(90.0, 1190.0), 605.0)
		2: return Vector2(90.0, randf_range(115.0, 605.0))
		_: return Vector2(1190.0, randf_range(115.0, 605.0))

func _spawn_boss() -> void:
	var boss := BOSS.instantiate()
	boss.position = Vector2(640, 100)
	add_child(boss)
	boss_label.text = "BOSS  500 / 500"
	boss_bar.value = 100.0
	$HUD/BossPanel.visible = true

func _update_boss_juice() -> void:
	if not boss_spawned:
		return
	var boss: Node = get_node_or_null("Boss")
	if boss == null:
		for child in get_children():
			if child is CharacterBody2D and child.has_method("take_damage") and child != player:
				boss = child
				break
	if boss != null and is_instance_valid(boss):
		boss_bar.value = (float(boss.health) / float(boss.max_health)) * 100.0
		boss_label.text = "BOSS  %03d / %03d" % [int(ceil(boss.health)), int(boss.max_health)]
	var pulse := 0.85 + sin(juice_time * 5.0) * 0.15
	boss_label.modulate.a = pulse
	boss_label.scale = Vector2.ONE * (1.0 + sin(juice_time * 5.0) * 0.03)

func claim_run_reward() -> void:
	if run_reward_claimed:
		return
	run_reward_claimed = true
	var reward: int = economy.claim_run_reward(int(survival_time))
	credits_label.text = "CREDITS  %04d  (+%d)" % [economy.get_credits(), reward]

func claim_rewarded_ad_placeholder() -> void:
	var reward: int = economy.claim_ad_reward_placeholder()
	if reward > 0:
		credits_label.text = "CREDITS  %04d  (+%d)" % [economy.get_credits(), reward]

func restart_run() -> void:
	_game_over_touch_lock = true
	game_over = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func exit_to_lobby() -> void:
	_game_over_touch_lock = true
	game_over = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func add_meta_core() -> void:
	meta_cores += 1

func get_meta_cores() -> int:
	return meta_cores

func _random_edge_position() -> Vector2:
	var edge := randi() % 4
	match edge:
		0: return Vector2(randf_range(60.0, 1220.0), 60.0)
		1: return Vector2(randf_range(60.0, 1220.0), 660.0)
		2: return Vector2(60.0, randf_range(60.0, 660.0))
		_: return Vector2(1220.0, randf_range(60.0, 660.0))

func _update_progression_hud() -> void:
	var level_label := $HUD/TopLeft/LevelLabel
	var xp_label := $HUD/TopLeft/XPLabel
	level_label.text = "LV  %02d" % player.level
	xp_label.text = "XP  %03d / %03d" % [player.xp, player.xp_to_next_level]
	xp_bar.value = (float(player.xp) / float(player.xp_to_next_level)) * 100.0

func _update_health_hud() -> void:
	var health_label := $HUD/StatusPanel/HealthLabel
	var health_bar := $HUD/StatusPanel/HealthBar
	health_label.text = "HULL  %03d / %03d" % [player.health, player.max_health]
	health_bar.value = (float(player.health) / float(player.max_health)) * 100.0

func _update_economy_hud() -> void:
	if is_instance_valid(economy) and is_instance_valid(credits_label):
		credits_label.text = "CREDITS  %04d" % economy.get_credits()
