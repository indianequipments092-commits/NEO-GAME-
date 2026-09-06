extends Node

const ENEMY := preload("res://scenes/enemy.tscn")
const MAX_ACTIVE := 24
const SPAWN_INTERVAL := 1.2

var spawn_timer := 0.0
var spawn_index := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Start with enemies already on-screen so the survival run never begins empty.
	for i in 4:
		_spawn_visible_enemy(i)

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		if _active_enemy_count() < MAX_ACTIVE:
			_spawn_visible_enemy(spawn_index)
			spawn_index += 1

func _active_enemy_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node):
			count += 1
	return count

func _spawn_visible_enemy(index: int) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var enemy := ENEMY.instantiate()
	enemy.add_to_group("enemies")
	enemy.z_index = 5
	var points := [Vector2(260, 250), Vector2(1020, 250), Vector2(260, 500), Vector2(1020, 500), Vector2(640, 180), Vector2(640, 540)]
	enemy.global_position = points[index % points.size()]
	scene.add_child(enemy)
