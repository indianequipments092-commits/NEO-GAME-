extends Control

## Phase 12 — adaptive neon landscape joystick and combat controls.
signal pause_requested
signal special_requested
signal dash_requested

const CYAN := Color("39d9ff")
const BLUE := Color("3d7dff")
const PURPLE := Color("a66cff")
const GREEN := Color("39f58a")
const TEXT := Color("dff8ff")

var joystick_center := Vector2.ZERO
var joystick_knob := Vector2.ZERO
var joystick_active := false
var joystick_id := -1
var fire_active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	if event is InputEventScreenTouch:
		var pos := event.position
		if event.pressed:
			if pos.x < size.x * 0.34 and pos.y > size.y * 0.55 and not joystick_active:
				joystick_active = true
				joystick_id = event.index
				joystick_center = Vector2(clamp(pos.x, 105.0, size.x * 0.30), clamp(pos.y, size.y * 0.72, size.y - 110.0))
				joystick_knob = joystick_center
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 115.0, size.y - 115.0), 72.0):
				fire_active = true
				Input.action_press("fire")
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 235.0, size.y - 175.0), 50.0):
				special_requested.emit()
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 255.0, size.y - 70.0), 45.0):
				dash_requested.emit()
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 48.0, 42.0), 34.0):
				pause_requested.emit()
				get_viewport().set_input_as_handled()
		else:
			if event.index == joystick_id:
				_release_movement()
			if fire_active and _in_circle(pos, Vector2(size.x - 115.0, size.y - 115.0), 90.0):
				fire_active = false
				Input.action_release("fire")
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == joystick_id:
		var max_radius := 70.0
		var delta := event.position - joystick_center
		if delta.length() > max_radius:
			delta = delta.normalized() * max_radius
		joystick_knob = joystick_center + delta
		_set_move_actions(delta / max_radius)
		get_viewport().set_input_as_handled()

func _release_movement() -> void:
	joystick_active = false
	joystick_id = -1
	joystick_knob = joystick_center
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)

func _set_move_actions(v: Vector2) -> void:
	if v.x < -0.18:
		Input.action_press("move_left", minf(1.0, absf(v.x)))
	else:
		Input.action_release("move_left")
	if v.x > 0.18:
		Input.action_press("move_right", minf(1.0, v.x))
	else:
		Input.action_release("move_right")
	if v.y < -0.18:
		Input.action_press("move_up", minf(1.0, absf(v.y)))
	else:
		Input.action_release("move_up")
	if v.y > 0.18:
		Input.action_press("move_down", minf(1.0, v.y))
	else:
		Input.action_release("move_down")

func _in_circle(p: Vector2, c: Vector2, radius: float) -> bool:
	return p.distance_to(c) <= radius

func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0 or size.y <= 0:
		return
	var center := joystick_center if joystick_center != Vector2.ZERO else Vector2(130, size.y - 125)
	var knob := joystick_knob if joystick_active else center
	_draw_ring(center, 82.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.16), 4.0)
	_draw_ring(center, 62.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.32), 2.0)
	draw_circle(center, 50.0, Color(0.02, 0.06, 0.14, 0.68))
	draw_circle(knob, 30.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.78))
	draw_circle(knob, 20.0, Color(0.03, 0.16, 0.32, 0.95))
	_draw_button(Vector2(size.x - 115.0, size.y - 115.0), 72.0, CYAN, "FIRE")
	_draw_button(Vector2(size.x - 235.0, size.y - 175.0), 50.0, PURPLE, "SPECIAL")
	_draw_button(Vector2(size.x - 255.0, size.y - 70.0), 45.0, GREEN, "DASH")
	_draw_button(Vector2(size.x - 48.0, 42.0), 26.0, BLUE, "Ⅱ")

func _draw_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	draw_arc(center, radius, 0.0, TAU, 64, color, width, true)

func _draw_button(center: Vector2, radius: float, color: Color, text: String) -> void:
	draw_circle(center, radius + 5.0, Color(color.r, color.g, color.b, 0.10))
	draw_arc(center, radius, 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.75), 3.0, true)
	draw_circle(center, radius - 7.0, Color(0.02, 0.05, 0.13, 0.72))
	var font := ThemeDB.fallback_font
	var fs := 13 if text.length() > 4 else 16
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, center + Vector2(-w / 2.0, fs / 2.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, TEXT)
