extends Node2D

# NEON SPACE SURVIVAL — Phase 5 enemies / boss / world content.
const XP_ORB := preload("res://scenes/xp_orb.tscn")
const ENEMY := preload("res://scenes/enemy.tscn")
const BOSS := preload("res://scenes/boss.tscn")

var survival_time := 0.0
var xp_spawn_time := 0.0
var enemy_spawn_time := 0.0
var xp_spawn_interval := 1.5
var enemy_spawn_interval := 2.5
var boss_spawned := false

@onready var timer_label: Label = $HUD/TimerLabel
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	timer_label.text = "SURVIVAL  00:00"
	_update_progression_hud()

func _process(delta: float) -> void:
	survival_time += delta
	xp_spawn_time += delta
	enemy_spawn_time += delta

	if xp_spawn_time >= xp_spawn_interval:
		xp_spawn_time = 0.0
		_spawn_xp_orb()

	if enemy_spawn_time >= enemy_spawn_interval and survival_time < 60.0:
		enemy_spawn_time = 0.0
		_spawn_enemy()

	if survival_time >= 60.0 and not boss_spawned:
		boss_spawned = true
		_spawn_boss()

	var total_seconds := int(survival_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "SURVIVAL  %02d:%02d" % [minutes, seconds]

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
	var boss_label := $HUD/BossLabel
	boss_label.visible = true

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
