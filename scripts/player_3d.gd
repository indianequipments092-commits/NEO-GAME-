extends CharacterBody3D

const WALK_SPEED := 7.0
const GRAVITY := 22.0
const MOUSE_SENSITIVITY := 0.0025
const MAX_HEALTH := 100

var health: int = MAX_HEALTH
var fire_cooldown := 0.0
var camera_pivot: Node3D
var spring_arm: SpringArm3D
var camera: Camera3D
var weapon_mesh: MeshInstance3D
var capsule_shape: CapsuleShape3D
var body_mesh: CapsuleMesh
var body_node: MeshInstance3D
var head_node: MeshInstance3D
var is_dead := false
var is_crouching := false

func _ready() -> void:
	name = "Player"
	add_to_group("player")
	var collision := CollisionShape3D.new()
	capsule_shape = CapsuleShape3D.new()
	capsule_shape.radius = 0.38
	capsule_shape.height = 1.8
	collision.shape = capsule_shape
	collision.position.y = 0.9
	add_child(collision)

	body_node = MeshInstance3D.new()
	body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.36
	body_mesh.height = 1.8
	body_node.mesh = body_mesh
	body_node.position.y = 0.9
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.12, 0.24, 0.32)
	body_mat.metallic = 0.18
	body_mat.roughness = 0.72
	body_node.material_override = body_mat
	add_child(body_node)

	head_node = MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head_node.mesh = head_mesh
	head_node.position = Vector3(0, 1.92, 0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.72, 0.53, 0.39)
	head_node.material_override = head_mat
	add_child(head_node)

	weapon_mesh = MeshInstance3D.new()
	var gun := BoxMesh.new()
	gun.size = Vector3(0.16, 0.16, 0.78)
	weapon_mesh.mesh = gun
	weapon_mesh.position = Vector3(0.38, 1.28, -0.42)
	var gun_mat := StandardMaterial3D.new()
	gun_mat.albedo_color = Color(0.12, 0.13, 0.15)
	gun_mat.metallic = 0.75
	weapon_mesh.material_override = gun_mat
	add_child(weapon_mesh)

	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position.y = 1.45
	add_child(camera_pivot)
	spring_arm = SpringArm3D.new()
	spring_arm.name = "CameraSpringArm"
	spring_arm.spring_length = 5.2
	spring_arm.margin = 0.25
	spring_arm.rotation_degrees.x = -13.0
	camera_pivot.add_child(spring_arm)
	camera = Camera3D.new()
	camera.name = "ThirdPersonCamera"
	camera.current = true
	spring_arm.add_child(camera)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("mobile") else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look_delta(event.relative, 1.0)
	elif event is InputEventScreenDrag:
		var viewport_width := get_viewport_rect().size.x
		if event.position.x >= viewport_width * 0.40:
			_apply_look_delta(event.relative, 1.8)

func _apply_look_delta(delta_position: Vector2, sensitivity_scale: float) -> void:
	camera_pivot.rotation.y -= delta_position.x * MOUSE_SENSITIVITY * sensitivity_scale
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - delta_position.y * MOUSE_SENSITIVITY * sensitivity_scale,
		deg_to_rad(-48),
		deg_to_rad(30)
	)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var crouch_now := Input.is_key_pressed(KEY_CTRL)
	if crouch_now != is_crouching:
		is_crouching = crouch_now
		capsule_shape.height = 1.3 if is_crouching else 1.8
		$CollisionShape3D.position.y = 0.65 if is_crouching else 0.9
		body_mesh.height = 1.3 if is_crouching else 1.8
		body_node.position.y = 0.65 if is_crouching else 0.9
		head_node.position.y = 1.42 if is_crouching else 1.92
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction := (right * input_vector.x + forward * -input_vector.y).normalized()
	var speed := WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 9.0
	elif is_crouching:
		speed = 3.4
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
		if Input.is_action_just_pressed("jump"):
			velocity.y = 7.0
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(1.0, delta * 10.0))
	move_and_slide()
	if Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		fire_weapon()

func fire_weapon() -> void:
	if is_dead or fire_cooldown > 0.0 or camera == null:
		return
	fire_cooldown = 0.22
	var origin := camera.global_position
	var end := origin + (-camera.global_basis.z) * 120.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [get_rid()]
	query.collide_with_areas = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var target = hit.get("collider")
		if target != null and target.has_method("take_damage"):
			target.take_damage(34)

func apply_damage(amount: int) -> void:
	if is_dead:
		return
	health = maxi(0, health - amount)
	if health <= 0:
		is_dead = true
		velocity = Vector3.ZERO
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
