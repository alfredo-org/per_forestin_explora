extends SceneTree
## Run with --script res://tests/glb_test.gd -- /absolute/path/fixture.glb.
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func finish() -> void:
	print("FORESTIN_GLB_RESULT failures=%d" % failures.size())
	quit(0 if failures.is_empty() else 1)

func run() -> void:
	var arguments := OS.get_cmdline_user_args()
	check(arguments.size() == 1, "Expected one GLB path after --")
	if arguments.size() != 1:
		finish()
		return
	var document := GLTFDocument.new()
	var state := GLTFState.new()
	var error := document.append_from_file(arguments[0], state)
	check(error == OK, "GLB import failed with error %d" % error)
	if error != OK:
		finish()
		return
	var imported := document.generate_scene(state)
	check(imported != null, "GLB scene generation failed")
	if imported == null:
		finish()
		return
	root.add_child(imported)
	await process_frame
	var meshes := imported.find_children("*", "MeshInstance3D", true, false)
	if imported is MeshInstance3D:
		meshes.append(imported)
	check(meshes.size() == 1, "Expected exactly one mesh; got %d" % meshes.size())
	if meshes.size() == 1:
		var mesh_instance := meshes[0] as MeshInstance3D
		check(mesh_instance.mesh != null, "MeshInstance3D has no mesh")
		if mesh_instance.mesh != null:
			var local_bounds := mesh_instance.mesh.get_aabb()
			var world_bounds: AABB = mesh_instance.global_transform * local_bounds
			check(local_bounds.size.is_equal_approx(Vector3(2, 2, 2)), "Local cube dimensions must be 2 meters")
			check(world_bounds.size.is_equal_approx(Vector3(2, 2, 2)), "World cube dimensions must remain 2 meters")
			check(world_bounds.get_center().is_equal_approx(Vector3.ZERO), "World cube center must remain at origin")
			check(mesh_instance.global_transform.basis.get_scale().is_equal_approx(Vector3.ONE), "Cube world scale must remain one")
			check(mesh_instance.mesh.get_surface_count() > 0, "Imported mesh has no surfaces")
			if mesh_instance.mesh.get_surface_count() > 0:
				check(mesh_instance.get_active_material(0) != null, "Fixture material was lost during GLB export/import")
	imported.queue_free()
	await process_frame
	finish()
