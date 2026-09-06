extends CharacterBody2D

## Large non-weapon contact hazard used as the Phase 5 boss encounter.
@export var move_speed: float = 48.0
@export var contact_damage: int = 18

var player: Node2D
var pulse_time := 0.0

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")
	var area := get_node_or_null("ContactArea")
	if area:
		area.body_entered.connect(_on_contact_body_entered)

func _physics_process(delta: float) -> void:
	pulse_time += delta
	if not is_instance_valid(player):
		player = get_tree().current_scene.get_node_or_null("Player")
		return
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()
	var visual := get_node_or_null("Visual")
	if visual:
		visual.scale = Vector2.ONE * (1.0 + sin(pulse_time * 3.0) * 0.05)

func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
