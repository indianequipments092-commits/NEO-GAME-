extends Node2D

# NEON SPACE SURVIVAL — final integration pass.
const XP_ORB := preload("res://scenes/xp_orb.tscn")
const ENEMY := preload("res://scenes/enemy.tscn")
const BOSS := preload("res://scenes/boss.tscn")

var survival_time := 0.0
var xp_spawn_time := 0.0
var enemy_spawn_time := 0.0
var xp_spawn_interval := 1.5
var enemy_spawn_interval := 2.5
var boss_spawned := false
var module_input_cooldown := 0.0
var meta_cores := 0
var juice_time := 0.0
var run_reward_claimed := false

@onready var timer_label: Label = $HUD/TimerLabel
@onready var player: CharacterBody2D = $Player
@onready var boss_label: Label = $HUD/BossLabel
@onready var economy: Node = $Economy
@onready var credits_label: Label = $HUD/CreditsLabel

func _ready() -> void:
	timer_label.text = "SURVIVAL  00:00"
	_update_progression_hud()
	_update_economy_hud()

func _process(delta: float) -> void:
	if get_tree().paused:
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
	var enemy := ENEMY.instantiate()
	enemy.position = _random_edge_position()
	add_child(enemy)

func _spawn_boss() -> void:
	var boss := BOSS.instantiate()
	boss.position = Vector2(640, 100)
	add_child(boss)
	boss_label.text = "BOSS  500 / 500"
	boss_label.visible = true

func _update_boss_juice() -> void:
	if not boss_spawned:
		return
	var pulse := 0.85 + sin(juice_time * 5.0) * 0.15
	boss_label.modulate.a = pulse
	boss_label.scale = Vector2.ONE * (1.0 + sin(juice_time * 5.0) * 0.03)

func claim_run_reward() -> void:
	if run_reward_claimed:
		return
	run_reward_claimed = true
	var reward := economy.claim_run_reward(int(survival_time))
	credits_label.text = "CREDITS  %04d  (+%d)" % [economy.get_credits(), reward]

func claim_rewarded_ad_placeholder() -> void:
	## Safe integration hook only; no live ad SDK is bundled in this project.
	var reward := economy.claim_ad_reward_placeholder()
	if reward > 0:
		credits_label.text = "CREDITS  %04d  (+%d)" % [economy.get_credits(), reward]

func restart_run() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func add_meta_core() -> void:
	meta_cores += 1

func get_meta_cores() -> int:
	return meta_cores

func _random_edge_position() -> Vector2:
	var edge := randi() % 4
	match edge:
		0:
			return Vector2(randf_range(60.0, 1220.0), 60.0)
		1:
			return Vector2(randf_range(60.0, 1220.0), 660.0)
		2:
			return Vector2(60.0, randf_range(60.0, 660.0))
		_:
			return Vector2(1220.0, randf_range(60.0, 660.0))

func _update_progression_hud() -> void:
	var level_label := $HUD/LevelLabel
	var xp_label := $HUD/XPLabel
	level_label.text = "LV  %02d" % player.level
	xp_label.text = "XP  %03d / %03d" % [player.xp, player.xp_to_next_level]

func _update_economy_hud() -> void:
	if is_instance_valid(economy) and is_instance_valid(credits_label):
		credits_label.text = "CREDITS  %04d" % economy.get_credits()
