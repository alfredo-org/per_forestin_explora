extends SceneTree
## Behavioral regressions for motion. Run with -- --no-save.
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if value:
		print("PASS " + message)
	else:
		failures += 1
		push_error(message)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func pose(node: Node3D) -> Dictionary:
	var result := {".": node.transform}
	for child in node.find_children("*", "Node3D", true, false):
		result[str(node.get_path_to(child))] = child.transform
	return result

func release_controls() -> void:
	for action in ["move_forward", "move_backward", "move_left", "move_right", "sprint", "jump"]:
		Input.action_release(action)

func run() -> void:
	check_pose_cycles()
	var scene = load("res://adventure/main.tscn").instantiate()
	root.add_child(scene)
	await frames(4)
	scene.no_save = true
	scene.start(false)
	await frames(60)
	var player = scene.player
	check(player.is_on_floor(), "motion fixture starts grounded")
	player.yaw = 0.0
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(40)
	check(player.animator.state == "run", "sprint reaches running animation")
	check(Vector2(player.velocity.x, player.velocity.z).length() > 5.0, "sprint reaches running speed")
	Input.action_release("sprint")
	await frames(30)
	check(player.animator.state == "walk", "releasing sprint transitions to walking")
	Input.action_release("move_forward")
	await frames(60)
	check(player.animator.state == "idle" and player.animator.blend < 0.05, "stopping input settles into idle")

	# Pause during ascent, while wildlife is also moving: disabling input alone
	# would fail these assertions because gravity and animation would continue.
	player.reset_to(scene.point(Vector2(-16, -21)) + Vector3.UP * 0.2)
	await frames(35)
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(7)
	check(not player.is_on_floor() and player.velocity.y > 0.0, "pause fixture catches ascending jump")
	scene.pause()
	var paused_position: Vector3 = player.global_position
	var paused_velocity: Vector3 = player.velocity
	var paused_pose := pose(player.visual)
	var animal_positions: Array[Vector3] = []
	var animal_poses: Array[Dictionary] = []
	for animal in scene.animals:
		animal_positions.append(animal.global_position)
		animal_poses.append(pose(animal.visual))
	Input.action_press("move_forward")
	await frames(45)
	Input.action_release("move_forward")
	check(player.global_position.is_equal_approx(paused_position), "pause freezes player in midair")
	check(player.velocity.is_equal_approx(paused_velocity), "pause preserves jump momentum")
	check(pose(player.visual) == paused_pose, "pause freezes player articulation")
	for i in range(scene.animals.size()):
		check(scene.animals[i].global_position.is_equal_approx(animal_positions[i]), "pause freezes guanaco %d position" % i)
		check(pose(scene.animals[i].visual) == animal_poses[i], "pause freezes guanaco %d articulation" % i)
	scene.resume()
	await frames(100)
	check(player.is_on_floor(), "resumed jump returns to terrain")
	check(player.animator.state == "idle", "landing settles to idle")

	# Use a real collider. Holding forward against it must stop locomotion
	# animation rather than deriving footsteps from desired input speed.
	player.reset_to(scene.point(Vector2(0, 10)) + Vector3.UP * 0.2)
	player.yaw = 0.0
	await frames(35)
	var wall := StaticBody3D.new()
	wall.position = player.global_position + Vector3(0, 1.0, -1.4)
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(5, 4, 0.4)
	collider.shape = box
	wall.add_child(collider)
	root.add_child(wall)
	await frames(3)
	Input.action_press("move_forward")
	await frames(90)
	var blocked_position: Vector3 = player.global_position
	await frames(30)
	check(player.global_position.distance_to(blocked_position) < 0.03, "wall blocks held movement input")
	check(player.animator.state == "idle" and player.animator.blend < 0.08, "blocked player stops walking animation")
	release_controls()
	wall.queue_free()
	await frames(4)

	# Reset from an airborne animated pose, then verify no stale blend/impact
	# survives the checkpoint teleport.
	Input.action_press("jump")
	await frames(1)
	Input.action_release("jump")
	await frames(7)
	player.reset_to(scene.point(Vector2(0, 12)) + Vector3.UP * 0.2)
	check(player.velocity.is_zero_approx(), "checkpoint reset clears momentum")
	check(player.animator.state == "idle" and is_zero_approx(player.animator.blend), "checkpoint reset clears locomotion state")
	check(is_zero_approx(player.animator.impact), "checkpoint reset clears landing impact")
	check(player.visual.position.is_zero_approx(), "checkpoint reset clears visual body offset")
	for path in ["LegL", "LegR", "LegL/Knee", "LegR/Knee", "LegL/Knee/Ankle", "LegR/Knee/Ankle", "ArmL", "ArmR", "ArmL/Elbow", "ArmR/Elbow"]:
		var joint := player.visual.get_node_or_null(path) as Node3D
		check(joint != null and joint.rotation.is_zero_approx(), "checkpoint clears joint " + path)
	release_controls()
	scene.queue_free()
	await frames(3)
	print("FORESTIN_MOTION_RESULT failures=%d" % failures)
	quit(1 if failures else 0)

func check_pose_cycles()->void:
	var model:=preload("res://adventure/forestin_model.gd").build()
	root.add_child(model)
	var motion=preload("res://adventure/character_motion.gd").new(model)
	var ranges:Array[float]=[]
	for speed in [3.2,6.0]:
		for frame in range(120):motion.update(1.0/60,speed,true,0,0)
		var lo:=INF;var hi:=-INF;var opposite:=0
		for frame in range(180):
			motion.update(1.0/60,speed,true,0,0)
			var left:float=model.get_node("ArmL").rotation.x
			var right:float=model.get_node("ArmR").rotation.x
			lo=minf(lo,left);hi=maxf(hi,left)
			if left*right<0:opposite+=1
		check(hi-lo>.5,"arms swing visibly through the gait cycle")
		check(opposite>100,"arms alternate in opposition")
		ranges.append(hi-lo)
	check(ranges[1]>ranges[0]*1.1,"running increases arm swing")
	for frame in range(120):motion.update(1.0/60,0,true,0,0)
	check(absf(model.get_node("ArmL").rotation.x)<.03,"arms settle after stopping")
	check(absf(model.get_node("LegL/Knee").rotation.x)<.35,"idle knees relax without deep crouch")
	motion.reset()
	var early:=0.0;var peak:=0.0
	for frame in range(630):
		motion.update(1.0/60,0,true,0,0)
		if frame<360:early=maxf(early,motion.smile)
		peak=maxf(peak,motion.smile)
	check(early<.02,"face starts neutral")
	check(peak>.8,"occasional smile eases in")
	check(motion.smile<.05,"smile returns to neutral")
	motion.clock=7.5
	for frame in range(30):motion.update(1.0/60,0,true,0,0)
	motion.reset()
	check(model.get_node("Head/Mouth").scale.is_equal_approx(Vector3.ONE),"checkpoint resets expression")
	model.free()
