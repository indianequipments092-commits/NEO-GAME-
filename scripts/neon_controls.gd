extends Control

## Phase 12 — premium landscape mobile controls, exit and three-dot pause menu.
const CYAN := Color("39d9ff")
const BLUE := Color("3d7dff")
const PURPLE := Color("a66cff")
const GREEN := Color("39f58a")
const RED := Color("ff4f6d")
const TEXT := Color("dff8ff")
const PANEL := Color("071329")

var joystick_center := Vector2.ZERO
var joystick_knob := Vector2.ZERO
var joystick_active := false
var joystick_id := -1
var fire_active := false
var menu_open := false
var special_cooldown := 0.0
var special_max := 10.0
var special_active := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()

func _process(delta: float) -> void:
	if special_cooldown > 0.0 and not get_tree().paused:
		special_cooldown = maxf(0.0, special_cooldown - delta)
	if special_active > 0.0:
		special_active = maxf(0.0, special_active - delta)
	queue_redraw()

func set_special_cooldown(value: float, maximum: float, active_time: float) -> void:
	special_cooldown = value
	special_max = maximum
	special_active = active_time
	queue_redraw()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	if event is InputEventScreenTouch:
		var pos := event.position
		if event.pressed:
			if menu_open:
				_handle_menu_touch(pos, size)
				get_viewport().set_input_as_handled()
				return
			if pos.x < size.x * 0.34 and pos.y > size.y * 0.55:
				joystick_active = true
				joystick_id = event.index
				joystick_center = Vector2(clamp(pos.x, 105.0, size.x * 0.30), clamp(pos.y, size.y * 0.72, size.y - 110.0))
				joystick_knob = joystick_center
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 115.0, size.y - 115.0), 76.0):
				fire_active = true
				Input.action_press("fire")
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 235.0, size.y - 175.0), 54.0):
				var player := get_tree().current_scene.get_node_or_null("Player")
				if player and player.has_method("activate_special"):
					player.activate_special()
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 255.0, size.y - 70.0), 48.0):
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 105.0, 42.0), 42.0):
				_reload_to_lobby()
				get_viewport().set_input_as_handled()
			elif _in_circle(pos, Vector2(size.x - 48.0, 42.0), 34.0):
				_open_three_dot_menu()
				get_viewport().set_input_as_handled()
		else:
			if event.index == joystick_id:
				_release_movement()
			if fire_active:
				fire_active = false
				Input.action_release("fire")
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == joystick_id and not menu_open:
		var max_radius := 70.0
		var delta := event.position - joystick_center
		if delta.length() > max_radius:
			delta = delta.normalized() * max_radius
		joystick_knob = joystick_center + delta
		_set_move_actions(delta / max_radius)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if menu_open:
			_close_three_dot_menu()
		else:
			_open_three_dot_menu()
		get_viewport().set_input_as_handled()

func _open_three_dot_menu() -> void:
	menu_open = true
	_release_movement()
	get_tree().paused = true
	queue_redraw()

func _close_three_dot_menu() -> void:
	menu_open = false
	get_tree().paused = false
	queue_redraw()

func _handle_menu_touch(pos: Vector2, size: Vector2) -> void:
	var x := size.x - 250.0
	var y := 105.0
	if Rect2(x, y, 230, 56).has_point(pos):
		_close_three_dot_menu()
	elif Rect2(x, y + 64, 230, 56).has_point(pos):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif Rect2(x, y + 128, 230, 56).has_point(pos):
		_reload_to_lobby()
	elif not Rect2(x, y, 230, 184).has_point(pos):
		_close_three_dot_menu()

func _reload_to_lobby() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _release_movement() -> void:
	joystick_active = false
	joystick_id = -1
	joystick_knob = joystick_center
	for action in ["move_left", "move_right", "move_up", "move_down"]:
		Input.action_release(action)

func _set_move_actions(v: Vector2) -> void:
	if v.x < -0.18: Input.action_press("move_left", minf(1.0, absf(v.x)))
	else: Input.action_release("move_left")
	if v.x > 0.18: Input.action_press("move_right", minf(1.0, v.x))
	else: Input.action_release("move_right")
	if v.y < -0.18: Input.action_press("move_up", minf(1.0, absf(v.y)))
	else: Input.action_release("move_up")
	if v.y > 0.18: Input.action_press("move_down", minf(1.0, v.y))
	else: Input.action_release("move_down")

func _in_circle(p: Vector2, c: Vector2, radius: float) -> bool:
	return p.distance_to(c) <= radius

func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0 or size.y <= 0: return
	var center := joystick_center if joystick_center != Vector2.ZERO else Vector2(130, size.y - 125)
	var knob := joystick_knob if joystick_active else center
	_draw_ring(center, 86.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.18), 4.0)
	_draw_ring(center, 66.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.34), 2.0)
	draw_circle(center, 52.0, Color(0.02, 0.06, 0.14, 0.76))
	draw_circle(knob, 31.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.82))
	draw_circle(knob, 21.0, Color(0.03, 0.16, 0.32, 0.98))
	_draw_button(Vector2(size.x - 115.0, size.y - 115.0), 74.0, CYAN, "FIRE")
	var special_color := GREEN if special_cooldown <= 0.0 else PURPLE
	_draw_button(Vector2(size.x - 235.0, size.y - 175.0), 52.0, special_color, "SPECIAL")
	_draw_button(Vector2(size.x - 255.0, size.y - 70.0), 47.0, GREEN, "DASH")
	_draw_button(Vector2(size.x - 105.0, 42.0), 34.0, BLUE, "EXIT")
	_draw_button(Vector2(size.x - 48.0, 42.0), 27.0, CYAN, "•••")
	if special_cooldown > 0.0:
		var font := ThemeDB.fallback_font
		var t := "%d" % int(ceil(special_cooldown))
		draw_string(font, Vector2(size.x - 235.0 - 7.0, size.y - 175.0 + 5.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, TEXT)
	if menu_open:
		_draw_pause_menu(size)

func _draw_pause_menu(size: Vector2) -> void:
	var panel_rect := Rect2(size.x - 260.0, 92.0, 245.0, 205.0)
	draw_style_box(_style_box(PANEL, CYAN, 0.97), panel_rect)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(panel_rect.position.x + 22, panel_rect.position.y + 30), "GAME MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
	_draw_menu_button(panel_rect.position + Vector2(8, 40), "▶  RESUME", GREEN)
	_draw_menu_button(panel_rect.position + Vector2(8, 104), "↻  RESTART", BLUE)
	_draw_menu_button(panel_rect.position + Vector2(8, 168), "⇥  EXIT", RED)

func _draw_menu_button(pos: Vector2, text: String, accent: Color) -> void:
	draw_style_box(_style_box(Color(accent.r, accent.g, accent.b, 0.10), accent, 0.85), Rect2(pos, Vector2(229, 52)))
	var font := ThemeDB.fallback_font
	draw_string(font, pos + Vector2(16, 33), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, TEXT)

func _style_box(bg: Color, border: Color, alpha: float) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = Color(border.r, border.g, border.b, alpha)
	s.set_border_width_all(2)
	s.set_corner_radius_all(12)
	return s

func _draw_ring(center: Vector2, radius: float, color: Color, width: float) -> void:
	draw_arc(center, radius, 0.0, TAU, 64, color, width, true)

func _draw_button(center: Vector2, radius: float, color: Color, text: String) -> void:
	draw_circle(center, radius + 5.0, Color(color.r, color.g, color.b, 0.10))
	draw_arc(center, radius, 0.0, TAU, 48, Color(color.r, color.g, color.b, 0.78), 3.0, true)
	draw_circle(center, radius - 7.0, Color(0.02, 0.05, 0.13, 0.74))
	var font := ThemeDB.fallback_font
	var fs := 12 if text.length() > 4 else 15
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, center + Vector2(-w / 2.0, fs / 2.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, TEXT)
