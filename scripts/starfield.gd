extends Node2D

## Procedural decorative starfield for Phase 7 polish.
@export var star_count: int = 90
@export var drift_speed: float = 12.0
var stars: Array[Vector2] = []
var sizes: Array[float] = []

func _ready() -> void:
	for i in star_count:
		stars.append(Vector2(randf_range(20.0, 1260.0), randf_range(20.0, 700.0)))
		sizes.append(randf_range(1.0, 2.5))
	queue_redraw()

func _process(delta: float) -> void:
	for i in stars.size():
		stars[i].y += drift_speed * delta * (0.5 + sizes[i] * 0.3)
		if stars[i].y > 720.0:
			stars[i].y = 0.0
			stars[i].x = randf_range(20.0, 1260.0)
	queue_redraw()

func _draw() -> void:
	for i in stars.size():
		draw_circle(stars[i], sizes[i], Color(0.35, 0.65, 0.9, 0.65))
