extends SceneTree
## Real renderer capture; requires a display (for example xvfb-run on CI).
var views:Dictionary={}
func _initialize()->void:call_deferred("run")
func capture(file:String)->void:
	for i in range(6):await process_frame
	await RenderingServer.frame_post_draw
	views[file]={"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)}
	var image:=root.get_texture().get_image()
	if image.is_empty() or image.save_png("res://../builds/reports/"+file)!=OK:push_error("Capture failed: "+file);quit(1)
func run()->void:
	root.size=Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute("res://../builds/reports")
	var scene=load("res://adventure/main.tscn").instantiate();root.add_child(scene)
	await capture("title.png")
	scene.start(false)
	for i in range(40):await physics_frame
	await capture("trail-day.png")
	scene.player.yaw=PI;scene.player.pitch=-0.10
	scene.player.arm.spring_length=3.5
	await capture("forestin.png")
	scene.player.arm.spring_length=5.0
	scene.player.yaw=0;scene.landscape.set_night(true)
	await capture("trail-night.png")
	scene.landscape.set_night(false)
	for animal in scene.animals:animal.active=false
	var animal:Node3D=scene.animals[0]
	var wildlife_camera:=Camera3D.new();scene.add_child(wildlife_camera);wildlife_camera.current=true
	wildlife_camera.global_position=animal.global_position+Vector3(3,1.8,4.5)
	wildlife_camera.look_at(animal.global_position+Vector3.UP*1.2)
	await capture("guanaco.png")
	var report:={"renderer":"OpenGL software CI", "resolution":"1280x720", "target_gpu_tested":false, "visible_objects":Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME), "draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "primitives":Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME), "nodes":get_node_count(), "views":views, "target_fps":"not measured"}
	var file:=FileAccess.open("res://../builds/reports/render-metrics.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));file.close()
	scene.queue_free()
	for i in range(3):await process_frame
	print("FORESTIN_CAPTURE_OK");quit()
