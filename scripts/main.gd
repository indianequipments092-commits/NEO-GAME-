extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_3d.gd")
const BOT_SCRIPT = preload("res://scripts/bot_3d.gd")
const BOT_COUNT := 8
var player
var status_label: Label
var message_label: Label
var alive_bots := BOT_COUNT
var elapsed := 0.0

func _ready() -> void:
	build_environment()
	build_island()
	build_landmarks()
	spawn_player()
	spawn_bots()
	build_hud()
	get_viewport().size_changed.connect(_layout_hud)
	_layout_hud()
	if not OS.has_feature("mobile"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("NEON 3D prototype ready: 1 player + %d offline bots" % BOT_COUNT)

func _process(delta: float) -> void:
	elapsed += delta
	alive_bots = get_tree().get_nodes_in_group("bots").size()
	if is_instance_valid(status_label) and is_instance_valid(player):
		status_label.text = "NEON 3D  |  HP %d  |  BOTS %d  |  %02d:%02d" % [player.health, alive_bots, int(elapsed) / 60, int(elapsed) % 60]
	if player != null and player.is_dead:
		message_label.text = "ELIMINATED — Press R to restart"
		message_label.visible = true
	elif alive_bots == 0:
		message_label.text = "WINNER! Island secured — Press R to play again"
		message_label.visible = true
	else:
		message_label.visible = false
	if Input.is_key_pressed(KEY_R) and (player.is_dead or alive_bots == 0):
		get_tree().reload_current_scene()

func build_environment() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.16, 0.35, 0.58)
	sky_material.sky_horizon_color = Color(0.72, 0.82, 0.87)
	sky_material.ground_bottom_color = Color(0.12, 0.19, 0.22)
	sky_material.ground_horizon_color = Color(0.52, 0.62, 0.58)
	sky.sky_material = sky_material
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.65, 0.72, 0.78)
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -25, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func build_island() -> void:
	var ocean := MeshInstance3D.new()
	var ocean_mesh := PlaneMesh.new()
	ocean_mesh.size = Vector2(600, 600)
	ocean.mesh = ocean_mesh
	ocean.position.y = -4.1
	var water := StandardMaterial3D.new()
	water.albedo_color = Color(0.035, 0.22, 0.31)
	water.metallic = 0.18
	water.roughness = 0.28
	ocean.material_override = water
	add_child(ocean)

	var island := StaticBody3D.new()
	island.name = "IslandGround"
	var ground_mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 86.0
	cylinder.bottom_radius = 91.0
	cylinder.height = 4.0
	ground_mesh.mesh = cylinder
	ground_mesh.position.y = -2.0
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color(0.23, 0.39, 0.22)
	ground_material.roughness = 1.0
	ground_mesh.material_override = ground_material
	island.add_child(ground_mesh)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := CylinderShape3D.new()
	ground_shape.radius = 86.0
	ground_shape.height = 4.0
	ground_collision.shape = ground_shape
	ground_collision.position.y = -2.0
	island.add_child(ground_collision)
	add_child(island)

func build_landmarks() -> void:
	# Main road and cross-road.
	make_box("MainRoad", Vector3(4.0, 0.08, 116.0), Vector3(0, 0.035, 0), Color(0.16, 0.18, 0.18))
	make_box("CrossRoad", Vector3(110.0, 0.08, 4.0), Vector3(0, 0.04, -8), Color(0.16, 0.18, 0.18))
	for i in range(15):
		var z := -48.0 + float(i) * 6.5
		make_box("RoadMark", Vector3(0.18, 0.025, 2.8), Vector3(0, 0.09, z), Color(0.88, 0.82, 0.54))

	# Small compound buildings, roofs and doors are all local primitives.
	var house_positions := [
		Vector3(15, 0, -24), Vector3(25, 0, -27), Vector3(-18, 0, -25),
		Vector3(-28, 0, -18), Vector3(18, 0, 18), Vector3(-18, 0, 22),
		Vector3(36, 0, 8), Vector3(-37, 0, 5), Vector3(8, 0, 39)
	]
	for i in range(house_positions.size()):
		var p: Vector3 = house_positions[i]
		var wall_color := Color(0.63, 0.56, 0.42) if i % 2 == 0 else Color(0.55, 0.62, 0.64)
		build_house(p, i, wall_color)
		make_box("Door_%d" % i, Vector3(1.0, 2.0, 0.12), p + Vector3(0, 1.0, -3.08), Color(0.18, 0.13, 0.1))

	# Palm-like trees around the roads and coastline.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261029
	for i in range(72):
		var angle := rng.randf_range(0.0, TAU)
		var radius := rng.randf_range(23.0, 77.0)
		var p := Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		if absf(p.x) < 5.0 or (absf(p.z + 8.0) < 5.0):
			continue
		if p.distance_to(Vector3(15, 0, -24)) < 9.0 or p.distance_to(Vector3(-18, 0, 22)) < 9.0:
			continue
		make_tree(p, rng.randf_range(0.8, 1.3), i)

func make_tree(p: Vector3, scale_value: float, index: int) -> void:
	var tree := Node3D.new()
	tree.name = "Tree_%d" % index
	tree.position = p
	tree.scale = Vector3.ONE * scale_value
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 2.4
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.2
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.25, 0.17, 0.1)
	trunk.material_override = trunk_mat
	tree.add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.2
	crown_mesh.height = 2.3
	crown.mesh = crown_mesh
	crown.position.y = 2.7
	var crown_mat := StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.12, 0.31 + float(index % 3) * 0.04, 0.15)
	crown_mat.roughness = 1.0
	crown.material_override = crown_mat
	tree.add_child(crown)
	var trunk_body := StaticBody3D.new()
	trunk_body.position.y = 1.2
	var trunk_collision := CollisionShape3D.new()
	var trunk_shape := CylinderShape3D.new()
	trunk_shape.radius = 0.28
	trunk_shape.height = 2.4
	trunk_collision.shape = trunk_shape
	trunk_body.add_child(trunk_collision)
	tree.add_child(trunk_body)
	add_child(tree)

func build_house(p: Vector3, index: int, wall_color: Color) -> void:
	var floor_color := wall_color.darkened(0.24)
	make_box("HouseFloor_%d" % index, Vector3(7.0, 0.2, 6.0), p, floor_color, true)
	make_box("HouseBack_%d" % index, Vector3(7.0, 3.2, 0.22), p + Vector3(0, 1.7, 2.9), wall_color, true)
	make_box("HouseLeft_%d" % index, Vector3(0.22, 3.2, 6.0), p + Vector3(-3.4, 1.7, 0), wall_color, true)
	make_box("HouseRight_%d" % index, Vector3(0.22, 3.2, 6.0), p + Vector3(3.4, 1.7, 0), wall_color, true)
	make_box("HouseFrontL_%d" % index, Vector3(2.8, 3.2, 0.22), p + Vector3(-2.1, 1.7, -2.9), wall_color, true)
	make_box("HouseFrontR_%d" % index, Vector3(2.8, 3.2, 0.22), p + Vector3(2.1, 1.7, -2.9), wall_color, true)
	make_box("HouseDoorHeader_%d" % index, Vector3(1.4, 0.55, 0.22), p + Vector3(0, 3.02, -2.9), wall_color, true)
	make_box("Roof_%d" % index, Vector3(7.6, 0.35, 6.6), p + Vector3(0, 3.48, 0), Color(0.25, 0.15, 0.12), true)
	for side in [-1.0, 1.0]:
		make_box("Window_%d_%d" % [index, int(side)], Vector3(0.95, 0.85, 0.035), p + Vector3(side * 1.75, 2.05, -3.025), Color(0.08, 0.16, 0.20), false)

func make_box(object_name: String, size: Vector3, pos: Vector3, color: Color, solid: bool = false) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = object_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mesh_instance.material_override = mat
	if solid:
		var body := StaticBody3D.new()
		body.name = object_name + "_Collision"
		body.position = pos
		add_child(body)
		mesh_instance.position = Vector3.ZERO
		body.add_child(mesh_instance)
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
	else:
		mesh_instance.position = pos
		add_child(mesh_instance)

func spawn_player() -> void:
	player = CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 0.15, 12)
	add_child(player)

func spawn_bots() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 72026
	for i in range(BOT_COUNT):
		var bot := CharacterBody3D.new()
		bot.set_script(BOT_SCRIPT)
		var angle := TAU * float(i) / float(BOT_COUNT) + rng.randf_range(-0.12, 0.12)
		var radius := rng.randf_range(46.0, 64.0)
		bot.position = Vector3(cos(angle) * radius, 0.15, sin(angle) * radius)
		add_child(bot)
		bot.setup(player, i)

func build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "BattleHUD"
	add_child(layer)
	status_label = Label.new()
	status_label.position = Vector2(22, 18)
	status_label.size = Vector2(780, 42)
	status_label.add_theme_font_size_override("font_size", 24)
	status_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0))
	status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	status_label.add_theme_constant_override("shadow_offset_x", 2)
	status_label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(status_label)

	message_label = Label.new()
	message_label.position = Vector2(280, 270)
	message_label.size = Vector2(720, 100)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 30)
	message_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.3))
	message_label.visible = false
	layer.add_child(message_label)

	make_hold_button(layer, "↑", Vector2(104, 510), "move_up")
	make_hold_button(layer, "←", Vector2(32, 578), "move_left")
	make_hold_button(layer, "↓", Vector2(104, 578), "move_down")
	make_hold_button(layer, "→", Vector2(176, 578), "move_right")
	var fire_button := Button.new()
	fire_button.name = "FireButton"
	fire_button.text = "FIRE"
	fire_button.position = Vector2(1090, 568)
	fire_button.size = Vector2(145, 95)
	fire_button.add_theme_font_size_override("font_size", 24)
	fire_button.add_theme_color_override("font_color", Color.WHITE)
	fire_button.modulate = Color(1.0, 0.34, 0.2, 0.92)
	fire_button.button_down.connect(func(): Input.action_press("fire"))
	fire_button.button_up.connect(func(): Input.action_release("fire"))
	layer.add_child(fire_button)

	var jump_button := Button.new()
	jump_button.name = "JumpButton"
	jump_button.text = "JUMP"
	jump_button.position = Vector2(920, 570)
	jump_button.size = Vector2(110, 70)
	jump_button.button_down.connect(func(): Input.action_press("jump"))
	jump_button.button_up.connect(func(): Input.action_release("jump"))
	layer.add_child(jump_button)

func _layout_hud() -> void:
	var size := get_viewport().get_visible_rect().size
	var layer := get_node_or_null("BattleHUD") as CanvasLayer
	if layer == null:
		return
	if is_instance_valid(status_label):
		status_label.position = Vector2(20, 18)
		status_label.size = Vector2(minf(size.x - 40.0, 780.0), 42)
	if is_instance_valid(message_label):
		message_label.position = Vector2((size.x - 720.0) * 0.5, (size.y - 100.0) * 0.5)
	var fire := layer.get_node_or_null("FireButton") as Button
	if fire:
		fire.position = Vector2(size.x - 165.0, size.y - 120.0)
	var jump := layer.get_node_or_null("JumpButton") as Button
	if jump:
		jump.position = Vector2(size.x - 300.0, size.y - 100.0)
	for entry in [
		["Button_move_up", Vector2(82.0, size.y - 172.0)],
		["Button_move_left", Vector2(14.0, size.y - 98.0)],
		["Button_move_down", Vector2(82.0, size.y - 98.0)],
		["Button_move_right", Vector2(150.0, size.y - 98.0)]
	]:
		var move_button := layer.get_node_or_null(entry[0]) as Button
		if move_button:
			move_button.position = entry[1]

func make_hold_button(layer: CanvasLayer, text_value: String, pos: Vector2, action: String) -> void:
	var button := Button.new()
	button.name = "Button_" + action
	button.text = text_value
	button.position = pos
	button.size = Vector2(66, 62)
	button.add_theme_font_size_override("font_size", 24)
	button.modulate = Color(0.75, 0.88, 0.95, 0.78)
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	layer.add_child(button)
