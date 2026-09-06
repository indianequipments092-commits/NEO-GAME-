extends Control

## Phase 12 — premium landscape touch controls.
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
var fire_id := -1
var menu_open := false
var special_cooldown := 0.0
var special_max := 10.0
var special_active := 0.0
var dash_feedback := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	var lobby := get_tree().current_scene.get_node_or_null("Menu/UI/MainPanel")
	if lobby:
		visible = not lobby.visible
	if not visible:
		return
	if special_cooldown > 0.0 and not get_tree().paused:
		special_cooldown = maxf(0.0, special_cooldown - delta)
	if special_active > 0.0:
		special_active = maxf(0.0, special_active - delta)
	if dash_feedback > 0.0 and not get_tree().paused:
		dash_feedback = maxf(0.0, dash_feedback - delta)
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
	if size.x <= 0.0 or size.y <= 0.0:
		return
	if event is InputEventScreenTouch:
		var pos := event.position
		if event.pressed:
			if menu_open:
				_handle_menu_touch(pos, size)
				get_viewport().set_input_as_handled()
				return
			if _in_rect(pos, Rect2(size.x - 145.0, 12.0, 70.0, 62.0)):
				exit_to_lobby()
				get_viewport().set_input_as_handled()
				return
			if _in_rect(pos, Rect2(size.x - 220.0, 12.0, 62.0, 62.0)):
				_open_three_dot_menu()
				get_viewport().set_input_as_handled()
				return
			if _in_circle(pos, _joystick_default_center(size), 92.0):
				joystick_active = true
				joystick_id = event.index
				joystick_center = _joystick_default_center(size)
				joystick_knob = joystick_center
				get_viewport().set_input_as_handled()
				return
			if _in_circle(pos, Vector2(size.x - 105.0, size.y - 110.0), 82.0):
				fire_active = true
				fire_id = event.index
				Input.action_press("fire")
				get_viewport().set_input_as_handled()
				return
			if _in_circle(pos, Vector2(size.x - 230.0, size.y - 178.0), 62.0):
				var player := get_tree().current_scene.get_node_or_null("Player")
				if player and player.has_method("activate_special"):
					player.activate_special()
				get_viewport().set_input_as_handled()
				return
			if _in_circle(pos, Vector2(size.x - 300.0, size.y - 82.0), 58.0):
				dash_feedback = 0.25
				var dash_player := get_tree().current_scene.get_node_or_null("Player")
				if dash_player and dash_player.has_method("perform_dash"):
					dash_player.perform_dash()
				get_viewport().set_input_as_handled()
				return
		else:
			if event.index == joystick_id:
				_release_movement()
			if event.index == fire_id:
				fire_active = false
				fire_id = -1
				Input.action_release("fire")
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if menu_open:
			return
		if event.index == joystick_id:
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
	Input.action_release("fire")
	fire_active = false
	fire_id = -1
	get_tree().paused = true
	queue_redraw()

func _close_three_dot_menu() -> void:
	menu_open = false
	get_tree().paused = false
	queue_redraw()

func _handle_menu_touch(pos: Vector2, size: Vector2) -> void:
	var x := size.x - 285.0
	var y := 125.0
	if Rect2(x, y, 270, 58).has_point(pos):
		_close_three_dot_menu()
	elif Rect2(x, y + 68, 270, 58).has_point(pos):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif Rect2(x, y + 136, 270, 58).has_point(pos):
		exit_to_lobby()
	elif not Rect2(x, y, 270, 205).has_point(pos):
		_close_three_dot_menu()

func exit_to_lobby() -> void:
	get_tree().paused = false
	menu_open = false
	Input.action_release("fire")
	_release_movement()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _joystick_default_center(size: Vector2) -> Vector2:
	return Vector2(125.0, size.y - 125.0)

func _release_movement() -> void:
	joystick_active = false
	joystick_id = -1
	joystick_knob = joystick_center if joystick_center != Vector2.ZERO else Vector2(125, 595)
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

func _in_rect(p: Vector2, r: Rect2) -> bool:
	return r.has_point(p)

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	if size.x <= 0 or size.y <= 0: return
	var center := _joystick_default_center(size)
	if joystick_center != Vector2.ZERO:
		center = joystick_center
	var knob := joystick_knob if joystick_active else center
	_draw_ring(center, 88.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.20), 4.0)
	_draw_ring(center, 70.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.38), 2.0)
	draw_circle(center, 56.0, Color(0.02, 0.06, 0.14, 0.80))
	_draw_chevron(center + Vector2(0, -39), Vector2.UP)
	_draw_chevron(center + Vector2(0, 39), Vector2.DOWN)
	_draw_chevron(center + Vector2(-39, 0), Vector2.LEFT)
	_draw_chevron(center + Vector2(39, 0), Vector2.RIGHT)
	draw_circle(knob, 32.0, Color(CYAN.r, CYAN.g, CYAN.b, 0.86))
	draw_circle(knob, 22.0, Color(0.03, 0.16, 0.32, 0.98))
	_draw_button(Vector2(size.x - 105.0, size.y - 110.0), 78.0, CYAN, "FIRE")
	var special_color := GREEN if special_cooldown <= 0.0 else PURPLE
	_draw_button(Vector2(size.x - 230.0, size.y - 178.0), 55.0, special_color, "SPECIAL")
	_draw_button(Vector2(size.x - 300.0, size.y - 82.0), 49.0, GREEN, "DASH")
	_draw_top_button(Rect2(size.x - 220.0, 12.0, 62.0, 62.0), CYAN, "•••")
	_draw_top_button(Rect2(size.x - 145.0, 12.0, 70.0, 62.0), BLUE, "EXIT")
	if special_cooldown > 0.0:
		var font := ThemeDB.fallback_font
		var t := "%d" % int(ceil(special_cooldown))
		draw_string(font, Vector2(size.x - 239.0, size.y - 172.0), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, TEXT)
	if menu_open:
		_draw_pause_menu(size)

func _draw_pause_menu(size: Vector2) -> void:
	var panel_rect := Rect2(size.x - 300.0, 95.0, 285.0, 245.0)
	draw_style_box(_style_box(PANEL, CYAN, 0.97), panel_rect)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(panel_rect.position.x + 22, panel_rect.position.y + 31), "GAME MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
	_draw_menu_button(panel_rect.position + Vector2(8, 42), "▶  RESUME", GREEN)
	_draw_menu_button(panel_rect.position + Vector2(8, 108), "↻  RESTART", BLUE)
	_draw_menu_button(panel_rect.position + Vector2(8, 174), "⇥  EXIT", RED)

func _draw_menu_button(pos: Vector2, text: String, accent: Color) -> void:
	draw_style_box(_style_box(Color(accent.r, accent.g, accent.b, 0.10), accent, 0.85), Rect2(pos, Vector2(269, 54)))
	var font := ThemeDB.fallback_font
	draw_string(font, pos + Vector2(16, 35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, TEXT)

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

func _draw_top_button(rect: Rect2, color: Color, text: String) -> void:
	draw_style_box(_style_box(Color(color.r, color.g, color.b, 0.10), color, 0.90), rect)
	var font := ThemeDB.fallback_font
	var fs := 15 if text == "EXIT" else 20
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	draw_string(font, rect.position + Vector2((rect.size.x - w) / 2.0, rect.size.y / 2.0 + fs / 2.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, TEXT)

func _draw_chevron(center: Vector2, direction: Vector2) -> void:
	var perp := Vector2(-direction.y, direction.x)
	var tip := center + direction * 7.0
	var a := center - direction * 5.0 + perp * 7.0
	var b := center - direction * 5.0 - perp * 7.0
	draw_polyline(PackedVector2Array([a, tip, b]), Color(CYAN.r, CYAN.g, CYAN.b, 0.8), 2.0, true)
