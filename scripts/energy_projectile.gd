extends Area2D

## Lightweight fictional energy projectile for the Phase 3 combat foundation.
@export var speed: float = 720.0
@export var lifetime: float = 1.4
@export var damage: float = 10.0

var direction := Vector2.UP
var remaining_lifetime := 0.0

func setup(start_position: Vector2, travel_direction: Vector2) -> void:
	global_position = start_position
	direction = travel_direction.normalized() if travel_direction.length_squared() > 0.0 else Vector2.UP
	rotation = direction.angle() + PI / 2.0

func _ready() -> void:
	remaining_lifetime = lifetime
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	remaining_lifetime -= delta
	if remaining_lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	_apply_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_apply_damage(area)

func _apply_damage(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
	queue_free()
