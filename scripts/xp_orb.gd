extends Area2D

## Collectible XP orb for Phase 4 progression.
@export var xp_value: int = 10
@export var drift_speed: float = 18.0
var age := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	age += delta
	position.y += sin(age * 5.0) * drift_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect_xp"):
		body.collect_xp(xp_value)
		queue_free()
