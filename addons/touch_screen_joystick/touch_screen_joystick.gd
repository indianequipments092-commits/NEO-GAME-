extends Control
class_name TouchScreenJoystick

## Floating joystick: touch anywhere in the movement area and the joystick
## appears under the finger, like a modern mobile shooter control.

@export var base_radius: float = 105.0
@export var knob_radius: float = 43.0
@export var deadzone: float = 18.0
@export var color: Color = Color("39d9ff")
@export var back_color: Color = Color(0.02, 0.06, 0.14, 0.72)
@export var thickness: float = 3.0
@export var use_input_actions: bool = true
@export var action_left: StringName = "move_left"
@export var action_right: StringName = "move_right"
@export var action_up: StringName = "move_up"
@export var action_down: StringName = "move_down"

## Touches in this fraction of the screen are treated as movement touches.
## The right side remains available for FIRE/SPECIAL/DASH controls.
@export_range(0.5, 0.9, 0.01) var movement_width_ratio: float = 0.68

var is_pressing := false
var event_index := -1
var base_position := Vector2.ZERO
var knob_position := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	visible = true
	queue_redraw()

func _draw() -> void:
	if not is_pressing:
		return
	var center := base_position
	var knob := knob_position
	draw_circle(center, base_radius + 6.0, Color(color.r, color.g, color.b, 0.08))
	draw_circle(center, base_radius, back_color)
	draw_arc(center, base_radius, 0.0, TAU, 64, Color(color.r, color.g, color.b, 0.75), thickness, true)
	draw_arc(center, base_radius - 18.0, 0.0, TAU, 64, Color(color.r, color.g, color.b, 0.20), 2.0, true)
	draw_circle(knob, knob_radius, Color(color.r, color.g, color.b, 0.90))
	draw_circle(knob, knob_radius - 10.0, Color(0.02, 0.10, 0.20, 0.96))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event_index == -1 and _can_start_at(event.position):
				event_index = event.index
				base_position = event.position
				knob_position = event.position
				is_pressing = true
				queue_redraw()
				get_viewport().set_input_as_handled()
		else:
			if event.index == event_index:
				_reset()
	elif event is InputEventScreenDrag and event.index == event_index and is_pressing:
		move_knob(event.position)
		get_viewport().set_input_as_handled()

func _can_start_at(pos: Vector2) -> bool:
	var viewport_size := get_viewport_rect().size
	if pos.x > viewport_size.x * movement_width_ratio:
		return false
	# Keep the top-right navigation controls free.
	if pos.y < 90.0 and pos.x > viewport_size.x - 340.0:
		return false
	return true

func move_knob(pos: Vector2) -> void:
	var delta := pos - base_position
	if delta.length() > base_radius:
		delta = delta.normalized() * base_radius
	knob_position = base_position + delta
	_set_actions(delta / base_radius)
	queue_redraw()

func _set_actions(v: Vector2) -> void:
	if not use_input_actions:
		return
	if absf(v.x) < 0.12:
		Input.action_release(action_left)
		Input.action_release(action_right)
	elif v.x < 0.0:
		Input.action_release(action_right)
		Input.action_press(action_left, absf(v.x))
	else:
		Input.action_release(action_left)
		Input.action_press(action_right, absf(v.x))
	if absf(v.y) < 0.12:
		Input.action_release(action_up)
		Input.action_release(action_down)
	elif v.y < 0.0:
		Input.action_release(action_down)
		Input.action_press(action_up, absf(v.y))
	else:
		Input.action_release(action_up)
		Input.action_press(action_down, absf(v.y))

func _reset() -> void:
	Input.action_release(action_left)
	Input.action_release(action_right)
	Input.action_release(action_up)
	Input.action_release(action_down)
	is_pressing = false
	event_index = -1
	base_position = Vector2.ZERO
	knob_position = Vector2.ZERO
	queue_redraw()
