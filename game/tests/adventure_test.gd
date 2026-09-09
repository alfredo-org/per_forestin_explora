extends SceneTree
const Progress=preload("res://adventure/progress.gd")
var failures:=0
func check(value:bool,message:String)->void:
	if not value:failures+=1;push_error(message)
	else:print("PASS "+message)
func frames(count:int)->void:
	for i in range(count):await physics_frame
func _initialize()->void:call_deferred("run")
func run()->void:
	var scene=load("res://adventure/main.tscn").instantiate();root.add_child(scene)
	await frames(4)
	scene.no_save=true;scene.start(false)
	await frames(50)
	check(scene.player.is_on_floor(),"player lands on terrain")
	check(not scene.interact() and scene.data.stage==0,"distant sign cannot advance mission")
	var origin:Vector3=scene.player.position
	Input.action_press("move_forward");await frames(50);Input.action_release("move_forward");await frames(15)
	check(scene.player.position.z<origin.z-1.5,"forward input moves player in camera direction")
	var before_jump:float=scene.player.position.y
	Input.action_press("jump");await frames(1);Input.action_release("jump");await frames(12)
	check(scene.player.position.y>before_jump+0.3,"jump lifts character")
	await frames(70);check(scene.player.is_on_floor(),"jump returns to ground")
	scene.pause();var paused_pos:Vector3=scene.player.position
	Input.action_press("move_forward");await frames(20);Input.action_release("move_forward")
	check(scene.player.position.distance_to(paused_pos)<0.05,"pause blocks movement input")
	scene.resume();scene.player.reset_to(scene.point(Vector2(0,1)))
	check(scene.interact() and scene.data.stage==1,"nearby sign opens wildlife objective")
	check(not scene.interact(),"wildlife objective requires sustained observation")
	for animal in scene.animals:animal.active=false
	scene.player.reset_to(scene.point(Vector2(-16,-12)))
	scene.player.yaw=0;scene.player.pitch=-0.05
	await frames(5)
	check(scene.can_observe(),"clear view at respectful distance detects wildlife")
	scene.observed=2
	check(scene.interact() and scene.data.stage==2,"observation advances wildlife objective")
	check(not scene.interact(),"distant rubbish cannot be collected")
	for i in range(3):
		scene.player.reset_to(scene.items[i].position+Vector3.UP*0.2)
		check(scene.interact(),"collect item %d"%i)
		if i<2:check(not scene.interact(),"item cannot be collected twice")
	check(scene.data.stage==3 and scene.data.collected.size()==3,"three unique items unlock final viewpoint")
	check(not scene.interact(),"final viewpoint requires proximity")
	scene.player.reset_to(scene.point(Vector2(-8,-81)))
	check(scene.interact() and scene.data.stage==4 and scene.ending.visible,"final viewpoint completes adventure")
	scene.resume();check(not scene.interact(),"completed mission cannot repeat rewards")
	var saved:Dictionary=scene.data.duplicate(true)
	scene.start(true);check(scene.data==saved,"continue preserves progress")
	scene.start(false);check(scene.data.stage==0 and scene.data.collected.is_empty(),"new game clears progression")
	for animal in scene.animals:animal.active=true
	scene.player.reset_to(scene.animals[0].position+Vector3(0,0,4));await frames(3)
	check(scene.animals[0].state=="retreat","close approach triggers wildlife retreat")
	check(Progress.sanitize({"version":1,"stage":4,"collected":[0,0,-1,9,"2"]}).stage==2,"malformed completion is repaired")
	check(Progress.sanitize({"version":999}).stage==0,"unknown save version resets safely")
	check(Progress.sanitize([1,2,3])==Progress.fresh(),"non-object save rejected")
	scene.landscape.set_night(true);check(scene.landscape.sun.light_energy<0.3,"night lighting applies")
	scene.landscape.apply_density("LOW");check(scene.landscape.grass_mesh.visible_instance_count==420,"low profile reduces grass")
	check(not scene.landscape.leaf_multimeshes.is_empty(),"landscape contains instanced tree foliage")
	for leaves in scene.landscape.leaf_multimeshes:
		check(leaves.visible_instance_count==405,"low profile reduces tree foliage")
	scene.landscape.apply_density("HIGH")
	check(scene.landscape.leaf_multimeshes[0].visible_instance_count==810,"high profile restores tree foliage")
	var test_save:="user://forestin_qa_%d.json"%Time.get_ticks_usec()
	check(Progress.save(saved,test_save),"save writes successfully")
	check(Progress.read(test_save)==saved,"save reload preserves complete progress")
	var broken:=FileAccess.open(test_save,FileAccess.WRITE);broken.store_string("{broken");broken.close()
	check(Progress.read(test_save)==Progress.fresh(),"corrupt file recovers safely")
	DirAccess.remove_absolute(test_save)
	scene.player.reset_to(scene.point(Vector2(0,10)));scene.player.yaw=0;scene.player.pitch=0
	var wall:=StaticBody3D.new();wall.position=scene.player.position+Vector3(0,1,2)
	var collider:=CollisionShape3D.new();var box:=BoxShape3D.new();box.size=Vector3(5,4,0.3);collider.shape=box;wall.add_child(collider);root.add_child(wall)
	await frames(12)
	check(scene.player.arm.get_hit_length()<2.5,"camera retracts before wall")
	wall.queue_free()
	scene.queue_free();await frames(3)
	print("FORESTIN_ADVENTURE_RESULT failures=%d"%failures);quit(1 if failures else 0)
