extends Node2D

## Lightweight Phase 7 game-juice controller.
@export var pulse_speed: float = 4.0
@export var pulse_strength: float = 0.08

var elapsed := 0.0
var base_scale := Vector2.ONE

func _ready() -> void:
	base_scale = scale

func _process(delta: float) -> void:
	elapsed += delta
	var pulse := 1.0 + sin(elapsed * pulse_speed) * pulse_strength
	scale = base_scale * pulse

func flash_label(label: Label, message: String, duration: float = 0.8) -> void:
	if not is_instance_valid(label):
		return
	label.text = message
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.35, duration)
	tween.tween_property(label, "modulate:a", 1.0, duration)
