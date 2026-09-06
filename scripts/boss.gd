extends CharacterBody2D

## Boss encounter with Phase 12 cinematic HUD integration.
@export var move_speed: float = 48.0
@export var contact_damage: int = 18
@export var max_health: float = 500.0
@export var xp_reward: int = 250

var health: float = 500.0
var player: Node2D
var pulse_time := 0.0

func _ready() -> void:
	health = max_health
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

func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(0.0, health - amount)
	var label := get_tree().current_scene.get_node_or_null("HUD/BossPanel/BossLabel")
	var bar := get_tree().current_scene.get_node_or_null("HUD/BossPanel/BossBar")
	if label:
		label.text = "BOSS  %03d / %03d" % [int(ceil(health)), int(max_health)]
	if bar:
		bar.value = (health / max_health) * 100.0
	if health <= 0.0:
		var scene := get_tree().current_scene
		if scene.has_method("spawn_enemy_xp"):
			scene.spawn_enemy_xp(global_position, xp_reward)
		if label:
			label.text = "BOSS DEFEATED"
		queue_free()

func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("take_contact_damage"):
		body.take_contact_damage(contact_damage)
