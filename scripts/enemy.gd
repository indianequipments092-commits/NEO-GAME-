extends CharacterBody2D

## Non-weapon contact hazard for Phase 5 world content.
@export var move_speed: float = 85.0
@export var contact_damage: int = 8
@export var xp_reward: int = 20

var player: Node2D

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")
	var area := get_node_or_null("ContactArea")
	if area:
		area.body_entered.connect(_on_contact_body_entered)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().current_scene.get_node_or_null("Player")
		return
	var direction := global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()

func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
