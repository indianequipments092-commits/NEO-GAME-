extends CanvasLayer

## Phase 12 — premium landscape UI controller.
const C_PANEL := Color("071329")
const C_CYAN := Color("39d9ff")
const C_BLUE := Color("3d7dff")
const C_PURPLE := Color("a66cff")
const C_PINK := Color("ff4fd8")
const C_GREEN := Color("39f58a")
const C_ORANGE := Color("ffb347")
const C_RED := Color("ff4f6d")
const C_TEXT := Color("dff8ff")
const C_MUTED := Color("7ea4c7")

@onready var pause_panel: Control = $UI/PausePanel
@onready var settings_panel: Control = $UI/SettingsPanel
@onready var main_panel: Control = $UI/MainPanel
@onready var content: Control = $UI/Content
var settings: Node
var panels: Dictionary = {}
var hud: CanvasLayer

func _ready() -> void:
	settings = get_node_or_null("../Settings")
	hud = get_node_or_null("../HUD")
	_build_ui()
	pause_panel.visible = false
	settings_panel.visible = false
	main_panel.visible = true
	content.visible = false
	if hud:
		hud.visible = false
	get_tree().paused = true
	_set_mobile_visible(false)

func _process(_delta: float) -> void:
	if main_panel.visible:
		var title := main_panel.get_node_or_null("Title")
		if title:
			title.modulate.a = 0.92 + sin(Time.get_ticks_msec() * 0.002) * 0.08

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_panel.visible:
			_close_settings()
		elif main_panel.visible:
			return
		else:
			_toggle_pause()

func _panel_style(border: Color = C_CYAN, alpha: float = 0.93) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(C_PANEL.r, C_PANEL.g, C_PANEL.b, alpha)
	s.border_color = Color(border.r, border.g, border.b, 0.78)
	s.set_border_width_all(2)
	s.set_corner_radius_all(16)
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 10
	return s

func _button_style(border: Color, active: bool = false) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(border.r, border.g, border.b, 0.16 if active else 0.08)
	s.border_color = Color(border.r, border.g, border.b, 0.9)
	s.set_border_width_all(2 if active else 1)
	s.set_corner_radius_all(10)
	return s

func _make_button(parent: Control, text: String, pos: Vector2, size: Vector2, accent: Color = C_CYAN) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_color_override("font_color", C_TEXT)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", C_GREEN)
	b.add_theme_stylebox_override("normal", _button_style(accent))
	b.add_theme_stylebox_override("hover", _button_style(accent, true))
	b.add_theme_stylebox_override("pressed", _button_style(C_GREEN, true))
	parent.add_child(b)
	b.mouse_entered.connect(func(): b.scale = Vector2(1.015, 1.015))
	b.mouse_exited.connect(func(): b.scale = Vector2.ONE)
	return b

func _make_label(parent: Control, text: String, pos: Vector2, size: Vector2, font_size: int, color: Color = C_TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = size
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l

func _build_ui() -> void:
	_build_main_panel()
	_build_content_panels()
	_build_pause_panel()
	_build_settings_panel()

func _build_main_panel() -> void:
	var p := main_panel
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.005, 0.01, 0.04, 0.92)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(dim)
	var card := Panel.new()
	card.position = Vector2(410, 85)
	card.size = Vector2(460, 550)
	card.add_theme_stylebox_override("panel", _panel_style(C_CYAN, 0.97))
	p.add_child(card)
	var title := _make_label(card, "NEON\nSPACE SURVIVAL", Vector2(25, 30), Vector2(410, 105), 38, C_TEXT)
	title.name = "Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_make_label(card, "SURVIVE  •  UPGRADE  •  EXPLORE", Vector2(30, 140), Vector2(400, 26), 13, C_CYAN).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var play := _make_button(card, "▶  PLAY", Vector2(65, 185), Vector2(330, 58), C_GREEN)
	play.pressed.connect(_on_play_pressed)
	var ship := _make_button(card, "✦  SHIP", Vector2(65, 255), Vector2(160, 48), C_CYAN)
	ship.pressed.connect(func(): _show_screen("SHIP"))
	var upgrade := _make_button(card, "⬆  UPGRADES", Vector2(235, 255), Vector2(160, 48), C_PURPLE)
	upgrade.pressed.connect(func(): _show_screen("UPGRADES"))
	var drones := _make_button(card, "◈  DRONES", Vector2(65, 313), Vector2(160, 48), C_BLUE)
	drones.pressed.connect(func(): _show_screen("DRONES"))
	var inventory := _make_button(card, "▣  INVENTORY", Vector2(235, 313), Vector2(160, 48), C_PINK)
	inventory.pressed.connect(func(): _show_screen("INVENTORY"))
	var missions := _make_button(card, "★  MISSIONS", Vector2(65, 371), Vector2(160, 48), C_ORANGE)
	missions.pressed.connect(func(): _show_screen("MISSIONS"))
	var settings_btn := _make_button(card, "⚙  SETTINGS", Vector2(235, 371), Vector2(160, 48), C_CYAN)
	settings_btn.pressed.connect(_on_settings_from_menu)
	var exit := _make_button(card, "EXIT", Vector2(145, 438), Vector2(170, 42), C_RED)
	exit.pressed.connect(func(): get_tree().quit())
	_make_label(card, "PHASE 12  •  PREMIUM LANDSCAPE UI", Vector2(20, 500), Vector2(420, 24), 11, C_MUTED).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _build_content_panels() -> void:
	var names := ["SHIP", "UPGRADES", "DRONES", "INVENTORY", "MISSIONS"]
	for n in names:
		var p := Panel.new()
		p.name = n
		p.position = Vector2(160, 85)
		p.size = Vector2(960, 550)
		p.add_theme_stylebox_override("panel", _panel_style(C_CYAN, 0.97))
		content.add_child(p)
		panels[n] = p
		_make_label(p, n, Vector2(30, 24), Vector2(700, 42), 30, C_TEXT)
		_make_label(p, "NEON SPACE SURVIVAL  /  PHASE 12", Vector2(32, 62), Vector2(500, 24), 11, C_MUTED)
		var back := _make_button(p, "‹  BACK", Vector2(790, 22), Vector2(130, 44), C_CYAN)
		back.pressed.connect(func(): _show_screen("MAIN"))
		_match_content(n, p)
		p.visible = false

func _match_content(n: String, p: Panel) -> void:
	match n:
		"SHIP":
			_make_label(p, "FALCON", Vector2(55, 125), Vector2(320, 45), 26, C_CYAN)
			_make_label(p, "LV 01  •  RARE SHIP", Vector2(55, 165), Vector2(300, 25), 13, C_PURPLE)
			_make_label(p, "◢────────────◣\n   ✦  SHIP PREVIEW  ✦\n◥────────────◤", Vector2(55, 215), Vector2(360, 180), 22, C_CYAN).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_make_label(p, "HULL       ████████░░  100\nDAMAGE     ██████░░░░   60\nSPEED      ███████░░░   75\nSHIELD     █████░░░░░   50\nFIRE RATE  ██████░░░░   65", Vector2(470, 135), Vector2(380, 190), 18, C_TEXT)
			var equip := _make_button(p, "EQUIP SHIP", Vector2(470, 360), Vector2(250, 52), C_GREEN)
			equip.pressed.connect(func(): equip.text = "✓ EQUIPPED")
			_make_label(p, "CUSTOMIZATION  •  WEAPON  •  SHIELD  •  ENGINE", Vector2(55, 455), Vector2(780, 28), 13, C_MUTED)
		"UPGRADES":
			var rows := ["LASER CANNON     LV 03     +30% DAMAGE", "MISSILE LAUNCHER  LV 02     +20% DAMAGE", "PLASMA CORE       LV 01     +15% FIRE RATE", "ENGINE MODULE     LV 02     +25 SPEED"]
			for i in rows.size():
				var y := 120.0 + i * 75.0
				var row := Panel.new()
				row.position = Vector2(45, y)
				row.size = Vector2(820, 58)
				row.add_theme_stylebox_override("panel", _panel_style(C_PURPLE, 0.55))
				p.add_child(row)
				_make_label(row, rows[i], Vector2(18, 15), Vector2(600, 28), 16, C_TEXT)
				var b := _make_button(row, "UPGRADE", Vector2(675, 8), Vector2(125, 42), C_GREEN)
				b.pressed.connect(func(btn=b): btn.text = "UPGRADED")
			_make_label(p, "Upgrade Points are earned through level-ups. Premium stat feedback is animated.", Vector2(50, 450), Vector2(820, 30), 13, C_MUTED)
		"DRONES":
			_make_label(p, "ACTIVE DRONE", Vector2(55, 120), Vector2(300, 32), 16, C_CYAN)
			_make_label(p, "◉\nCOMBAT DRONE\nLV 02", Vector2(80, 175), Vector2(240, 160), 26, C_BLUE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			_make_label(p, "DAMAGE     25\nFIRE RATE   2.0/s\nHEALTH      150\nABILITY     SUPPORT PULSE", Vector2(390, 145), Vector2(350, 150), 18, C_TEXT)
			var b := _make_button(p, "UPGRADE  •  800", Vector2(390, 325), Vector2(240, 52), C_GREEN)
			b.pressed.connect(func(): b.text = "✓ UPGRADED")
			_make_label(p, "Additional drones unlock through progression and meta systems.", Vector2(55, 460), Vector2(780, 30), 13, C_MUTED)
		"INVENTORY":
			var tabs := ["ALL", "WEAPONS", "DRONES", "MODULES", "ITEMS"]
			for i in tabs.size():
				_make_button(p, tabs[i], Vector2(45 + i * 145, 105), Vector2(130, 40), C_CYAN if i == 0 else C_BLUE)
			for i in 8:
				var slot := Panel.new()
				slot.position = Vector2(55 + (i % 4) * 190, 175 + (i / 4) * 125)
				slot.size = Vector2(165, 105)
				slot.add_theme_stylebox_override("panel", _panel_style(C_PURPLE if i % 2 else C_CYAN, 0.65))
				p.add_child(slot)
				_make_label(slot, "✦\nITEM %02d\nRARE" % (i + 1), Vector2(8, 12), Vector2(149, 85), 17, C_TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		"MISSIONS":
			_make_label(p, "DAILY   •   WEEKLY   •   ACHIEVEMENTS", Vector2(45, 105), Vector2(700, 30), 15, C_ORANGE)
			var missions := ["Defeat 50 enemies     0/50     ★50", "Collect 10 XP cores    0/10     ★100", "Survive 5 minutes      0/5      ★150", "Upgrade any module    0/3      ★75"]
			for i in missions.size():
				var y := 155.0 + i * 70.0
				_make_label(p, missions[i], Vector2(55, y), Vector2(650, 45), 17, C_TEXT)
				var b := _make_button(p, "GO", Vector2(760, y - 4), Vector2(90, 42), C_CYAN)
				b.pressed.connect(func(btn=b): btn.text = "✓")

func _build_pause_panel() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.01, 0.05, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_panel.add_child(dim)
	var card := Panel.new()
	card.position = Vector2(440, 160)
	card.size = Vector2(400, 400)
	card.add_theme_stylebox_override("panel", _panel_style(C_CYAN, 0.98))
	pause_panel.add_child(card)
	_make_label(card, "PAUSED", Vector2(20, 28), Vector2(360, 50), 32, C_CYAN).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var resume := _make_button(card, "▶  RESUME", Vector2(50, 105), Vector2(300, 50), C_GREEN)
	resume.pressed.connect(_on_resume_pressed)
	var restart := _make_button(card, "↻  RESTART", Vector2(50, 165), Vector2(300, 50), C_BLUE)
	restart.pressed.connect(func(): get_tree().paused = false; get_tree().reload_current_scene())
	var set := _make_button(card, "⚙  SETTINGS", Vector2(50, 225), Vector2(300, 50), C_PURPLE)
	set.pressed.connect(_on_settings_pressed)
	var menu := _make_button(card, "⌂  MAIN MENU", Vector2(50, 285), Vector2(300, 50), C_PINK)
	menu.pressed.connect(_return_to_main)

func _build_settings_panel() -> void:
	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.01, 0.05, 0.82)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_panel.add_child(dim)
	var card := Panel.new()
	card.position = Vector2(365, 70)
	card.size = Vector2(550, 580)
	card.add_theme_stylebox_override("panel", _panel_style(C_PURPLE, 0.98))
	settings_panel.add_child(card)
	_make_label(card, "SETTINGS", Vector2(25, 25), Vector2(500, 45), 30, C_TEXT).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var groups := ["GENERAL", "GRAPHICS", "AUDIO", "CONTROLS", "LANGUAGE"]
	for i in groups.size():
		_make_label(card, groups[i], Vector2(45, 95 + i * 72), Vector2(130, 32), 14, C_CYAN)
		var bar := ProgressBar.new()
		bar.position = Vector2(180, 95 + i * 72)
		bar.size = Vector2(260, 28)
		bar.value = [100, 75, 80, 65, 100][i]
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", _button_style(C_BLUE))
		bar.add_theme_stylebox_override("fill", _button_style(C_CYAN, true))
		card.add_child(bar)
	var back := _make_button(card, "‹  BACK", Vector2(175, 490), Vector2(200, 48), C_CYAN)
	back.pressed.connect(_close_settings)

func _show_screen(screen: String) -> void:
	main_panel.visible = screen == "MAIN"
	content.visible = screen != "MAIN"
	for key in panels:
		panels[key].visible = key == screen
	_set_mobile_visible(false)

func _on_play_pressed() -> void:
	main_panel.visible = false
	content.visible = false
	if hud:
		hud.visible = true
	get_tree().paused = false
	_set_mobile_visible(true)

func _toggle_pause() -> void:
	pause_panel.visible = not pause_panel.visible
	get_tree().paused = pause_panel.visible
	_set_mobile_visible(not pause_panel.visible)

func _on_resume_pressed() -> void:
	pause_panel.visible = false
	get_tree().paused = false
	_set_mobile_visible(true)

func _on_settings_pressed() -> void:
	pause_panel.visible = false
	settings_panel.visible = true
	_set_mobile_visible(false)

func _on_settings_from_menu() -> void:
	main_panel.visible = false
	settings_panel.visible = true
	_set_mobile_visible(false)

func _close_settings() -> void:
	settings_panel.visible = false
	if get_tree().paused:
		pause_panel.visible = true
	else:
		main_panel.visible = true
	_set_mobile_visible(false)

func _return_to_main() -> void:
	pause_panel.visible = false
	main_panel.visible = true
	content.visible = false
	if hud:
		hud.visible = false
	get_tree().paused = true
	_set_mobile_visible(false)

func _set_mobile_visible(value: bool) -> void:
	var mobile := get_parent().get_node_or_null("MobileControls")
	if mobile:
		mobile.visible = value and DisplayServer.is_touchscreen_available()
