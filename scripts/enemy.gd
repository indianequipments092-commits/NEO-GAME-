extends CharacterBody2D

## Basic enemy for the Phase 5 world-content loop.
@export var move_speed: float = 85.0
@export var contact_damage: int = 8
@export var xp_reward: int = 20
@export var max_health: float = 30.0

var health: float = 30.0
var player: Node2D

func _ready() -> void:
	health = max_health
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

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(0.0, health - amount)
	if health <= 0.0:
		var scene := get_tree().current_scene
		if scene.has_method("spawn_enemy_xp"):
			scene.spawn_enemy_xp(global_position, xp_reward)
		queue_free()

func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
