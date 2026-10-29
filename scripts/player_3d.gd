extends CharacterBody3D

const WALK_SPEED := 7.0
const GRAVITY := 22.0
const MOUSE_SENSITIVITY := 0.0025
const MAX_HEALTH := 100

var health: int = MAX_HEALTH
var fire_cooldown := 0.0
var camera_pivot: Node3D
var camera: Camera3D
var weapon_mesh: MeshInstance3D
var is_dead := false

func _ready() -> void:
	name = "Player"
	add_to_group("player")
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.36
	body_mesh.height = 1.8
	body.mesh = body_mesh
	body.position.y = 0.9
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.12, 0.24, 0.32)
	body_mat.metallic = 0.18
	body_mat.roughness = 0.72
	body.material_override = body_mat
	add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head.mesh = head_mesh
	head.position = Vector3(0, 1.92, 0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.72, 0.53, 0.39)
	head.material_override = head_mat
	add_child(head)

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
	camera = Camera3D.new()
	camera.name = "ThirdPersonCamera"
	camera.position = Vector3(0, 1.55, 5.2)
	camera.rotation_degrees.x = -13.0
	camera.current = true
	camera_pivot.add_child(camera)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if OS.has_feature("mobile") else Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-48), deg_to_rad(30))

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var forward := -camera_pivot.global_basis.z
	var right := camera_pivot.global_basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var direction := (right * input_vector.x + forward * -input_vector.y).normalized()
	velocity.x = direction.x * WALK_SPEED
	velocity.z = direction.z * WALK_SPEED
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), minf(1.0, delta * 10.0))
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
