extends Node2D

## Autonomous support drone for Phase 6.
@export var orbit_radius: float = 70.0
@export var orbit_speed: float = 1.8
@export var pulse_interval: float = 1.2

var orbit_angle := 0.0
var pulse_time := 0.0
var pulse_count := 0
var player: Node2D

func _ready() -> void:
	player = get_tree().current_scene.get_node_or_null("Player")

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().current_scene.get_node_or_null("Player")
		return

	orbit_angle += orbit_speed * delta
	pulse_time += delta
	global_position = player.global_position + Vector2.from_angle(orbit_angle) * orbit_radius
	rotation = orbit_angle

	if pulse_time >= pulse_interval:
		pulse_time = 0.0
		pulse_count += 1
		if player.has_method("drone_support_pulse"):
			player.drone_support_pulse()
