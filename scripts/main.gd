extends Node2D

# NEON SPACE SURVIVAL — Phase 4 XP / level / roguelite progression.
const XP_ORB := preload("res://scenes/xp_orb.tscn")
var survival_time := 0.0
var xp_spawn_time := 0.0
var xp_spawn_interval := 1.5

@onready var timer_label: Label = $HUD/TimerLabel
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	timer_label.text = "SURVIVAL  00:00"
	_update_progression_hud()

func _process(delta: float) -> void:
	survival_time += delta
	xp_spawn_time += delta
	if xp_spawn_time >= xp_spawn_interval:
		xp_spawn_time = 0.0
		_spawn_xp_orb()

	var total_seconds := int(survival_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "SURVIVAL  %02d:%02d" % [minutes, seconds]

func _spawn_xp_orb() -> void:
	var orb := XP_ORB.instantiate()
	var margin := 80.0
	orb.position = Vector2(
		randf_range(margin, 1280.0 - margin),
		randf_range(margin, 720.0 - margin)
	)
	add_child(orb)

func _update_progression_hud() -> void:
	var level_label := $HUD/LevelLabel
	var xp_label := $HUD/XPLabel
	level_label.text = "LV  %02d" % player.level
	xp_label.text = "XP  %03d / %03d" % [player.xp, player.xp_to_next_level]
