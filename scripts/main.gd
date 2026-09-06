extends Node2D

# NEON SPACE SURVIVAL — Phase 2 core gameplay loop.
var survival_time := 0.0

@onready var timer_label: Label = $HUD/TimerLabel

func _ready() -> void:
	timer_label.text = "SURVIVAL  00:00"

func _process(delta: float) -> void:
	survival_time += delta
	var total_seconds := int(survival_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "SURVIVAL  %02d:%02d" % [minutes, seconds]
