extends "res://scripts/menu.gd"

const LOBBY_BG := preload("res://assets/ui/neon_lobby_background.svg")

func _build_main_panel() -> void:
	var p := main_panel
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# The reference artwork is the visual layer; transparent controls sit exactly on top.
	var bg := TextureRect.new()
	bg.name = "ReferenceLobby"
	bg.texture = LOBBY_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(bg)

	var title := Label.new()
	title.name = "Title"
	title.text = ""
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(title)

	# Transparent touch/click hitboxes. The artwork itself supplies all visible buttons/icons.
	_add_hit(p, "PlayLeft", Rect2(18, 150, 345, 88), _on_play_pressed)
	_add_hit(p, "Ship", Rect2(18, 245, 345, 72), func(): _show_screen("SHIP"))
	_add_hit(p, "Upgrades", Rect2(18, 325, 345, 72), func(): _show_screen("UPGRADES"))
	_add_hit(p, "Drones", Rect2(18, 405, 345, 72), func(): _show_screen("DRONES"))
	_add_hit(p, "Inventory", Rect2(18, 485, 345, 72), func(): _show_screen("INVENTORY"))
	_add_hit(p, "Missions", Rect2(18, 565, 345, 72), func(): _show_screen("MISSIONS"))
	_add_hit(p, "Settings", Rect2(18, 645, 345, 72), _on_settings_from_menu)
	_add_hit(p, "CenterPlay", Rect2(515, 640, 505, 175), _on_play_pressed)
	_add_hit(p, "DailyMissions", Rect2(1150, 125, 360, 315), func(): _show_screen("MISSIONS"))
	_add_hit(p, "AdReward", Rect2(1150, 455, 360, 150), func(): _show_screen("MISSIONS"))
	_add_hit(p, "FreeReward", Rect2(1150, 625, 360, 115), func(): _show_screen("MISSIONS"))
	_add_hit(p, "Trophy", Rect2(1285, 20, 75, 80), func(): _show_screen("MISSIONS"))
	_add_hit(p, "Mail", Rect2(1370, 20, 75, 80), func(): _show_screen("MISSIONS"))
	_add_hit(p, "TopSettings", Rect2(1450, 20, 75, 80), _on_settings_from_menu)

func _add_hit(parent: Control, node_name: String, rect: Rect2, action: Callable) -> void:
	var b := Button.new()
	b.name = node_name
	b.position = rect.position
	b.size = rect.size
	b.text = ""
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_filter = Control.MOUSE_FILTER_STOP
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0, 0, 0, 0)
	empty.border_width_left = 0
	empty.border_width_top = 0
	empty.border_width_right = 0
	empty.border_width_bottom = 0
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("hover", empty)
	b.add_theme_stylebox_override("pressed", empty)
	b.add_theme_stylebox_override("focus", empty)
	parent.add_child(b)
	b.pressed.connect(action)
