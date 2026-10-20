extends Node3D

# Initial 3D prototype. Procedural placeholder players are used until proper licensed/original character assets are added.
const FIELD_LENGTH := 52.0
const FIELD_WIDTH := 32.0
const MOVE_SPEED := 7.0
const BALL_KICK_POWER := 13.0

var player: CharacterBody3D
var ball: RigidBody3D
var camera_3d: Camera3D
var opponent: CharacterBody3D
var ai_players: Array[CharacterBody3D] = []
var animation_clock := 0.0
var animation_parts: Dictionary = {}
var hud_label: Label
var touch_vector := Vector2.ZERO
var action_pass := false
var action_shoot := false
var score_home := 0
var score_away := 0
var match_time := 90.0
var time_label: Label
var kick_cooldown := 0.0

func _ready() -> void:
	_build_world()
	_build_ui()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_world() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.65, 0.8)
	env.ambient_light_energy = 0.65
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	add_child(sun)

	_make_box("PitchBase", Vector3(FIELD_WIDTH, 0.3, FIELD_LENGTH), Vector3(0, -0.25, 0), Color(0.035, 0.34, 0.12))
	for i in range(8):
		var strip_color := Color(0.05, 0.40, 0.15) if i % 2 == 0 else Color(0.04, 0.36, 0.13)
		_make_box("TurfStrip", Vector3(FIELD_WIDTH, 0.015, FIELD_LENGTH / 8.0), Vector3(0, -0.08, -FIELD_LENGTH / 2.0 + FIELD_LENGTH / 16.0 + i * FIELD_LENGTH / 8.0), strip_color)

	_make_box("HalfwayLine", Vector3(FIELD_WIDTH, 0.025, 0.12), Vector3(0, -0.055, 0), Color.WHITE)
	_make_box("LeftTouchline", Vector3(0.12, 0.025, FIELD_LENGTH), Vector3(-FIELD_WIDTH / 2.0, -0.055, 0), Color.WHITE)
	_make_box("RightTouchline", Vector3(0.12, 0.025, FIELD_LENGTH), Vector3(FIELD_WIDTH / 2.0, -0.055, 0), Color.WHITE)
	_make_box("NearGoalLine", Vector3(FIELD_WIDTH, 0.025, 0.12), Vector3(0, -0.055, FIELD_LENGTH / 2.0), Color.WHITE)
	_make_box("FarGoalLine", Vector3(FIELD_WIDTH, 0.025, 0.12), Vector3(0, -0.055, -FIELD_LENGTH / 2.0), Color.WHITE)
	_make_circle(Vector3(0, -0.04, 0), 4.0, Color.WHITE)
	_make_box("CenterSpot", Vector3(0.25, 0.04, 0.25), Vector3(0, -0.025, 0), Color.WHITE)
	_make_box("HomeGoalBar", Vector3(7.0, 0.18, 0.18), Vector3(0, 2.4, FIELD_LENGTH / 2.0 - 0.5), Color.WHITE)
	_make_box("HomePostL", Vector3(0.18, 2.5, 0.18), Vector3(-3.5, 1.2, FIELD_LENGTH / 2.0 - 0.5), Color.WHITE)
	_make_box("HomePostR", Vector3(0.18, 2.5, 0.18), Vector3(3.5, 1.2, FIELD_LENGTH / 2.0 - 0.5), Color.WHITE)
	_make_box("AwayGoalBar", Vector3(7.0, 0.18, 0.18), Vector3(0, 2.4, -FIELD_LENGTH / 2.0 + 0.5), Color.WHITE)
	_make_box("AwayPostL", Vector3(0.18, 2.5, 0.18), Vector3(-3.5, 1.2, -FIELD_LENGTH / 2.0 + 0.5), Color.WHITE)
	_make_box("AwayPostR", Vector3(0.18, 2.5, 0.18), Vector3(3.5, 1.2, -FIELD_LENGTH / 2.0 + 0.5), Color.WHITE)

	player = _make_player("HomePlayer", Vector3(0, 0.1, 9), Color(0.05, 0.45, 1.0))
	opponent = _make_player("Opponent", Vector3(0, 0.1, -5), Color(0.9, 0.08, 0.1))
	ai_players.append(opponent)
	ai_players.append(_make_player("BlueTeammate", Vector3(-6, 0.1, 5), Color(0.05, 0.45, 1.0)))
	ai_players.append(_make_player("RedDefender", Vector3(6, 0.1, -10), Color(0.9, 0.08, 0.1)))
	ai_players.append(_make_player("RedWing", Vector3(-7, 0.1, -3), Color(0.9, 0.08, 0.1)))
	ball = RigidBody3D.new()
	ball.name = "Football"
	ball.position = Vector3(0.8, 0.55, 7.5)
	ball.mass = 0.45
	ball.linear_damp = 0.8
	ball.angular_damp = 0.6
	var ball_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.38
	sphere.height = 0.76
	ball_mesh.mesh = sphere
	var ball_mat := StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.95, 0.95, 0.88)
	ball_mat.roughness = 0.6
	ball_mesh.material_override = ball_mat
	ball.add_child(ball_mesh)
	var ball_collision := CollisionShape3D.new()
	var ball_shape := SphereShape3D.new()
	ball_shape.radius = 0.38
	ball_collision.shape = ball_shape
	ball.add_child(ball_collision)
	add_child(ball)

	camera_3d = Camera3D.new()
	camera_3d.name = "FollowCamera"
	camera_3d.current = true
	camera_3d.fov = 68
	add_child(camera_3d)
	_update_camera(0.0)

func _make_box(label: String, size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	item.mesh = mesh
	item.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	item.material_override = mat
	add_child(item)
	return item

func _make_circle(pos: Vector3, radius: float, color: Color) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.055
	torus.outer_radius = radius + 0.055
	ring.mesh = torus
	ring.position = pos
	ring.rotation_degrees.x = 90
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	ring.material_override = mat
	add_child(ring)

func _make_player(label: String, pos: Vector3, kit_color: Color) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.name = label
	body.position = pos
	var shape_node := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.48
	capsule.height = 1.9
	shape_node.shape = capsule
	shape_node.position.y = 0.95
	body.add_child(shape_node)
	var kit := StandardMaterial3D.new()
	kit.albedo_color = kit_color
	kit.roughness = 0.55
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.47, 0.29, 0.19)
	var shorts_mat := StandardMaterial3D.new()
	shorts_mat.albedo_color = Color(0.06, 0.07, 0.09)
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.radius = 0.43
	torso_mesh.height = 0.95
	torso.mesh = torso_mesh
	torso.position.y = 1.18
	torso.material_override = kit
	body.add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.27
	head_mesh.height = 0.54
	head.mesh = head_mesh
	head.position.y = 1.93
	head.material_override = skin
	body.add_child(head)
	# Shoulder pivots let the arms swing while the player runs.
	var arm_pivots: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		var arm_pivot := Node3D.new()
		arm_pivot.position = Vector3(side * 0.4, 1.55, 0.02)
		body.add_child(arm_pivot)
		var arm := MeshInstance3D.new()
		var arm_mesh := CapsuleMesh.new()
		arm_mesh.radius = 0.12
		arm_mesh.height = 0.72
		arm.mesh = arm_mesh
		arm.position = Vector3(side * 0.08, -0.28, 0.0)
		arm.rotation_degrees.z = side * -12.0
		arm.material_override = kit
		arm_pivot.add_child(arm)
		arm_pivots.append(arm_pivot)
	var hair := MeshInstance3D.new()
	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.275
	hair_mesh.height = 0.25
	hair.mesh = hair_mesh
	hair.position = Vector3(0, 2.13, 0.015)
	var hair_mat := StandardMaterial3D.new()
	hair_mat.albedo_color = Color(0.055, 0.035, 0.02)
	hair.material_override = hair_mat
	body.add_child(hair)
	# Nose, ears and simple mouth give the prototype head more readable features.
	var nose := MeshInstance3D.new()
	var nose_mesh := SphereMesh.new()
	nose_mesh.radius = 0.055
	nose_mesh.height = 0.09
	nose.mesh = nose_mesh
	nose.position = Vector3(0, 1.91, -0.27)
	nose.material_override = skin
	body.add_child(nose)
	for side in [-1.0, 1.0]:
		var ear := MeshInstance3D.new()
		var ear_mesh := SphereMesh.new()
		ear_mesh.radius = 0.07
		ear_mesh.height = 0.12
		ear.mesh = ear_mesh
		ear.position = Vector3(side * 0.25, 1.92, 0.0)
		ear.material_override = skin
		body.add_child(ear)
	var mouth := MeshInstance3D.new()
	var mouth_mesh := BoxMesh.new()
	mouth_mesh.size = Vector3(0.12, 0.025, 0.025)
	mouth.mesh = mouth_mesh
	mouth.position = Vector3(0, 1.83, -0.25)
	var mouth_mat := StandardMaterial3D.new()
	mouth_mat.albedo_color = Color(0.12, 0.035, 0.025)
	mouth.material_override = mouth_mat
	body.add_child(mouth)
	for side in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.035
		eye_mesh.height = 0.05
		eye.mesh = eye_mesh
		eye.position = Vector3(side * 0.09, 1.96, -0.235)
		var eye_mat := StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.025, 0.02, 0.015)
		eye.material_override = eye_mat
		body.add_child(eye)
	var shorts := MeshInstance3D.new()
	var shorts_mesh := BoxMesh.new()
	shorts_mesh.size = Vector3(0.72, 0.34, 0.43)
	shorts.mesh = shorts_mesh
	shorts.position.y = 0.63
	shorts.material_override = shorts_mat
	body.add_child(shorts)
	var leg_pivots: Array[Node3D] = []
	for side in [-1.0, 1.0]:
		var leg_pivot := Node3D.new()
		leg_pivot.position = Vector3(side * 0.2, 0.55, 0)
		body.add_child(leg_pivot)
		var leg := MeshInstance3D.new()
		var leg_mesh := CapsuleMesh.new()
		leg_mesh.radius = 0.13
		leg_mesh.height = 0.68
		leg.mesh = leg_mesh
		leg.position = Vector3(0, -0.28, 0)
		leg.material_override = shorts_mat
		leg_pivot.add_child(leg)
		var boot := MeshInstance3D.new()
		var boot_mesh := BoxMesh.new()
		boot_mesh.size = Vector3(0.23, 0.12, 0.38)
		boot.mesh = boot_mesh
		boot.position = Vector3(0, -0.5, -0.08)
		var boot_mat := StandardMaterial3D.new()
		boot_mat.albedo_color = Color(0.025, 0.025, 0.03)
		boot.material_override = boot_mat
		leg_pivot.add_child(boot)
		leg_pivots.append(leg_pivot)
	add_child(body)
	if label != "HomePlayer":
		body.add_to_group("football_ai")
	animation_parts[body.get_instance_id()] = {"legs": leg_pivots, "arms": arm_pivots}
	return body

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(18, 15)
	panel.custom_minimum_size = Vector2(250, 70)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	panel.add_child(box)
	hud_label = Label.new()
	hud_label.text = "NEON FOOTBALL ARENA  |  BLUE 0 - 0 RED"
	hud_label.add_theme_font_size_override("font_size", 18)
	box.add_child(hud_label)
	time_label = Label.new()
	time_label.text = "MATCH: 90"
	box.add_child(time_label)
	var hint := Label.new()
	hint.text = "MOVE: WASD / ARROWS     PASS: SPACE     SHOOT: ENTER"
	hint.position = Vector2(18, 92)
	hint.add_theme_font_size_override("font_size", 15)
	layer.add_child(hint)
	var controls := HBoxContainer.new()
	controls.anchor_left = 0.0
	controls.anchor_top = 1.0
	controls.anchor_right = 1.0
	controls.anchor_bottom = 1.0
	controls.offset_left = 18
	controls.offset_top = -95
	controls.offset_right = -18
	controls.offset_bottom = -12
	controls.add_theme_constant_override("separation", 12)
	layer.add_child(controls)
	var left_box := HBoxContainer.new()
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(left_box)
	_add_hold_button(left_box, "◀", Vector2(-1, 0))
	_add_hold_button(left_box, "▲", Vector2(0, -1))
	_add_hold_button(left_box, "▼", Vector2(0, 1))
	_add_hold_button(left_box, "▶", Vector2(1, 0))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.add_child(spacer)
	var right_box := HBoxContainer.new()
	controls.add_child(right_box)
	_add_action_button(right_box, "PASS", false)
	_add_action_button(right_box, "SHOOT", true)

func _add_hold_button(parent: Control, caption: String, direction: Vector2) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(58, 62)
	button.button_down.connect(func(): touch_vector = direction)
	button.button_up.connect(func():
		if touch_vector == direction:
			touch_vector = Vector2.ZERO)
	parent.add_child(button)

func _add_action_button(parent: Control, caption: String, shooting: bool) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(82, 62)
	if shooting:
		button.button_down.connect(func(): action_shoot = true)
		button.button_up.connect(func(): action_shoot = false)
	else:
		button.button_down.connect(func(): action_pass = true)
		button.button_up.connect(func(): action_pass = false)
	parent.add_child(button)

func _process(delta: float) -> void:
	animation_clock += delta
	for body in [player, opponent]:
		_animate_player(body)
	for body in get_tree().get_nodes_in_group("football_ai"):
		_animate_player(body)

func _animate_player(body: Node) -> void:
	if not is_instance_valid(body) or not body is CharacterBody3D:
		return
	var parts: Dictionary = animation_parts.get(body.get_instance_id(), {})
	if parts.is_empty():
		return
	var velocity: Vector3 = body.velocity
	var speed := Vector2(velocity.x, velocity.z).length()
	var intensity := clampf(speed / MOVE_SPEED, 0.0, 1.0)
	var phase := animation_clock * (7.5 + speed * 1.2)
	var legs: Array = parts.get("legs", [])
	var arms: Array = parts.get("arms", [])
	for i in range(legs.size()):
		legs[i].rotation.x = sin(phase + float(i) * PI) * 0.62 * intensity
		legs[i].rotation.z = 0.0
	for i in range(arms.size()):
		arms[i].rotation.x = sin(phase + float(i) * PI + PI) * 0.28 * intensity
		arms[i].rotation.z = 0.0
	body.position.y = 0.1 + absf(sin(phase * 2.0)) * 0.06 * intensity

func _physics_process(delta: float) -> void:
	if player == null:
		return
	match_time = maxf(0.0, match_time - delta)
	time_label.text = "MATCH: %02d" % int(match_time)
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	if touch_vector != Vector2.ZERO:
		input_dir = touch_vector
	input_dir = input_dir.normalized()
	player.velocity.x = input_dir.x * MOVE_SPEED
	player.velocity.z = input_dir.y * MOVE_SPEED
	if input_dir.length() > 0.05:
		player.rotation.y = atan2(input_dir.x, -input_dir.y)
	player.velocity.y -= 22.0 * delta
	player.move_and_slide()
	player.position.x = clampf(player.position.x, -FIELD_WIDTH / 2.0 + 1.0, FIELD_WIDTH / 2.0 - 1.0)
	player.position.z = clampf(player.position.z, -FIELD_LENGTH / 2.0 + 1.0, FIELD_LENGTH / 2.0 - 1.0)
	_update_camera(delta)
	kick_cooldown = maxf(0.0, kick_cooldown - delta)
	if Input.is_action_just_pressed("pass_ball") or action_pass:
		_kick_ball(false)
	if Input.is_action_just_pressed("shoot_ball") or action_shoot:
		_kick_ball(true)
	if is_instance_valid(opponent) and ball != null:
		var to_ball := ball.global_position - opponent.global_position
		to_ball.y = 0
		if to_ball.length() > 1.4:
			opponent.velocity.x = to_ball.normalized().x * 2.3
			opponent.velocity.z = to_ball.normalized().z * 2.3
			opponent.velocity.y -= 22.0 * delta
			opponent.move_and_slide()
	_check_goal()

func _update_camera(_delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(camera_3d):
		return
	var target := player.global_position + Vector3(0, 1.0, 0)
	var desired := target + Vector3(0, 8.5, 12.5)
	camera_3d.global_position = camera_3d.global_position.lerp(desired, 0.12)
	camera_3d.look_at(target + Vector3(0, 0, -2.0), Vector3.UP)

func _kick_ball(shooting: bool) -> void:
	if kick_cooldown > 0.0 or not is_instance_valid(ball):
		return
	if player.global_position.distance_to(ball.global_position) > 3.2:
		return
	var direction := -player.global_transform.basis.z
	if direction.length() < 0.1:
		direction = Vector3(0, 0, -1)
	direction.y = 0
	direction = direction.normalized()
	var power := BALL_KICK_POWER if shooting else BALL_KICK_POWER * 0.48
	ball.apply_central_impulse(direction * power + Vector3.UP * (4.5 if shooting else 1.2))
	kick_cooldown = 0.55

func _check_goal() -> void:
	if ball.global_position.z < -FIELD_LENGTH / 2.0 and absf(ball.global_position.x) < 3.6:
		score_home += 1
		_reset_ball()
	elif ball.global_position.z > FIELD_LENGTH / 2.0 and absf(ball.global_position.x) < 3.6:
		score_away += 1
		_reset_ball()
	hud_label.text = "NEON FOOTBALL ARENA  |  BLUE %d - %d RED" % [score_home, score_away]

func _reset_ball() -> void:
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.global_position = Vector3(0, 0.55, 0)
