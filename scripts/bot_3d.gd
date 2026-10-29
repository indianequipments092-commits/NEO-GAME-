extends CharacterBody3D

const GRAVITY := 22.0
var target: CharacterBody3D
var health := 100
var attack_timer := 0.0
var strafe_sign := 1.0
var dead := false

func setup(player: CharacterBody3D, index: int) -> void:
	target = player
	strafe_sign = -1.0 if index % 2 == 0 else 1.0

func _ready() -> void:
	add_to_group("bots")
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.36
	shape.height = 1.75
	collision.shape = shape
	collision.position.y = 0.88
	add_child(collision)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.34
	body_mesh.height = 1.72
	body.mesh = body_mesh
	body.position.y = 0.86
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.52, 0.17, 0.12)
	material.roughness = 0.8
	body.material_override = material
	add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.21
	head_mesh.height = 0.42
	head.mesh = head_mesh
	head.position.y = 1.82
	var head_material := StandardMaterial3D.new()
	head_material.albedo_color = Color(0.68, 0.49, 0.36)
	head.material_override = head_material
	add_child(head)

func _physics_process(delta: float) -> void:
	if dead or not is_instance_valid(target) or target.is_dead:
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		move_and_slide()
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	var offset: Vector3 = target.global_position - global_position
	offset.y = 0.0
	var distance := offset.length()
	if distance > 5.0:
		var direction := offset.normalized()
		velocity.x = direction.x * 2.6
		velocity.z = direction.z * 2.6
		rotation.y = atan2(direction.x, direction.z)
	elif distance > 2.0:
		var side := Vector3(-offset.z, 0.0, offset.x).normalized() * strafe_sign
		velocity.x = side.x * 1.1
		velocity.z = side.z * 1.1
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	if distance < 14.0 and attack_timer <= 0.0:
		attack_timer = 1.45
		target.apply_damage(7)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.5
	move_and_slide()

func take_damage(amount: int) -> void:
	if dead:
		return
	health = maxi(0, health - amount)
	if health == 0:
		dead = true
		queue_free()
