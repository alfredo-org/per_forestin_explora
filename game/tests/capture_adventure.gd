extends SceneTree
## Real renderer capture; requires a display (for example xvfb-run on CI).
func _initialize()->void:call_deferred("run")
func capture(file:String)->void:
	for i in range(12):await process_frame
	await RenderingServer.frame_post_draw
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
	await capture("forestin.png")
	scene.player.yaw=0;scene.landscape.set_night(true)
	await capture("trail-night.png")
	scene.queue_free()
	for i in range(3):await process_frame
	print("FORESTIN_CAPTURE_OK");quit()
