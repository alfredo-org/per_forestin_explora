extends SceneTree
## Run: godot --headless --path game --script res://tests/smoke_test.gd
const QualityProfiles = preload("res://core/quality_profiles.gd")
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func run() -> void:
	var scene := load("res://scenes/bootstrap.tscn") as PackedScene
	if scene == null:
		push_error("Bootstrap scene failed to load")
		quit(1)
		return
	var instance := scene.instantiate()
	root.add_child(instance)
	await process_frame
	for action in ["move_forward", "move_backward", "move_left", "move_right", "look_left", "look_right", "look_up", "look_down", "jump", "sprint", "interact", "pause"]:
		check(InputMap.has_action(action), "Missing action: " + action)
		check(not InputMap.action_get_events(action).is_empty(), "Unbound action: " + action)
	var camera := instance.get_node_or_null("Camera3D") as Camera3D
	var sun := instance.get_node_or_null("Sun") as DirectionalLight3D
	check(camera != null and camera.current, "No active camera")
	check(sun != null, "No directional light")
	var collision := instance.get_node_or_null("Ground/Collision") as CollisionShape3D
	check(collision != null and collision.shape is BoxShape3D, "Missing ground collision")
	if camera != null and sun != null:
		for profile in QualityProfiles.PROFILES:
			check(QualityProfiles.apply(profile, root, camera, sun), "Profile rejected: " + profile)
			var expected: Dictionary = QualityProfiles.PROFILES[profile]
			check(is_equal_approx(root.scaling_3d_scale, expected.scale), "Resolution scale mismatch: " + profile)
			check(root.msaa_3d == expected.msaa, "MSAA mismatch: " + profile)
			check(sun.shadow_enabled == expected.shadows, "Shadow mismatch: " + profile)
			check(is_equal_approx(camera.far, expected.far), "Draw distance mismatch: " + profile)
		check(not QualityProfiles.apply("INVALID", root, camera, sun), "Invalid profile accepted")
	await physics_frame
	await physics_frame
	var world := (instance as Node3D).get_world_3d()
	var query := PhysicsRayQueryParameters3D.create(Vector3(2, 3, 0), Vector3(2, -2, 0))
	var hit := world.direct_space_state.intersect_ray(query)
	check(not hit.is_empty(), "Ground does not collide with downward ray")
	if not hit.is_empty():
		check(is_zero_approx(hit.position.y), "Ground must be at y=0")
	instance.queue_free()
	await process_frame
	print("FORESTIN_SMOKE_RESULT failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)
