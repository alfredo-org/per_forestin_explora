extends Node3D
const Landscape=preload("res://adventure/landscape.gd")
const Player=preload("res://adventure/player.gd")
const Wildlife=preload("res://adventure/wildlife.gd")
const Shapes=preload("res://adventure/shapes.gd")
const Progress=preload("res://adventure/progress.gd")
const Quality=preload("res://core/quality_profiles.gd")
const CHECKPOINTS:=[Vector2(0,12),Vector2(-8,-17),Vector2(-1,-40),Vector2(-6,-71),Vector2(-8,-82)]
const PICKUPS:=[Vector2(-1,-45),Vector2(-2,-54),Vector2(-4,-63)]
var landscape:Node3D
var player:CharacterBody3D
var animals:Array[CharacterBody3D]=[]
var items:Array[Node3D]=[]
var data:Dictionary
var running:=false
var paused:=false
var no_save:=false
var quality:="HIGH"
var observed:=0.0
var toast_time:=0.0
var ui_time:=0.0
var menu:Control
var hud:Control
var pause_ui:Control
var ending:Control
var objective:Label
var detail:Label
var hint:Label
var toast_label:Label
var distance_label:Label
var quality_button:Button
var night_button:Button
var marker:Node3D
var ambience:AudioStreamPlayer
var chime:AudioStreamPlayer
var footsteps:AudioStreamPlayer
var step_timer:=0.0
func _ready()->void:
	data=Progress.read()
	for arg in OS.get_cmdline_user_args():
		if arg=="--no-save":no_save=true;data=Progress.fresh()
		if arg.begins_with("--quality=") and Quality.PROFILES.has(arg.trim_prefix("--quality=")):quality=arg.trim_prefix("--quality=")
	landscape=Landscape.new();landscape.quality=quality;add_child(landscape);landscape.set_night(data.night)
	player=Player.new();player.name="Player";add_child(player);player.reset_to(point(CHECKPOINTS[0])+Vector3.UP*0.25)
	for i in range(3):
		var animal:=Wildlife.new();animal.name="Guanaco%d"%i;animal.home=point(Vector2(-16-i*2,-25-i*4));animal.position=animal.home+Vector3.UP*0.1;animal.player=player;add_child(animal);animals.append(animal)
	for pos in [Vector2(0,0),Vector2(-10,-23),Vector2(-8,-82)]:signpost(pos,"SENDERO DEL MIRADOR\nObserva · Respeta · Conserva")
	for i in range(3):
		var item:=Node3D.new();item.position=point(PICKUPS[i])+Vector3.UP*0.12;add_child(item)
		var bottle:=Shapes.capsule(item,Vector3.ZERO,0.09,0.33,Shapes.material(Color("a9c8b4"),0.35));bottle.rotation.z=1.2
		var ring:=MeshInstance3D.new();var torus:=TorusMesh.new();torus.inner_radius=0.32;torus.outer_radius=0.37;torus.rings=16;torus.ring_segments=6;ring.mesh=torus;ring.position.y=0.09
		var gold:=Shapes.material(Color("d8bb7d"));gold.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ring.material_override=gold;item.add_child(ring);items.append(item)
	marker=Shapes.ellipsoid(self,Vector3.ZERO,Vector3(0.18,0.27,0.18),Shapes.material(Color("efca70")))
	make_ui();sync_items();setup_audio();Quality.apply(quality,get_viewport(),player.camera,landscape.sun);landscape.apply_density(quality)
	print("FORESTIN_ADVENTURE_READY")
func point(p:Vector2)->Vector3:return Vector3(p.x,Landscape.height_at(p.x,p.y),p.y)
func label(parent:Node,text:String,size:int,color:Color=Color("f4eee0"))->Label:
	var result:=Label.new();result.text=text;result.add_theme_font_size_override("font_size",size);result.add_theme_color_override("font_color",color);parent.add_child(result);return result
func style(color:Color,padding:int=18)->StyleBoxFlat:
	var result:=StyleBoxFlat.new();result.bg_color=color;result.set_corner_radius_all(12);result.set_content_margin_all(padding);return result
func button(parent:Node,text:String,callback:Callable)->Button:
	var b:=Button.new();b.text=text;b.custom_minimum_size=Vector2(300,44);b.add_theme_font_size_override("font_size",17)
	b.add_theme_stylebox_override("normal",style(Color("d6bc86"),10));b.add_theme_stylebox_override("hover",style(Color("eee0b5"),10));b.add_theme_color_override("font_color",Color("183328"));b.add_theme_color_override("font_hover_color",Color("183328"));parent.add_child(b);b.pressed.connect(callback);return b
func screen(canvas:CanvasLayer)->Control:
	var c:=Control.new();canvas.add_child(c);c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);c.mouse_filter=Control.MOUSE_FILTER_IGNORE;return c
func darken(parent:Control,alpha:float)->void:
	var shade:=ColorRect.new();shade.color=Color(0.012,0.035,0.024,alpha);parent.add_child(shade);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
func column(parent:Control,pos:Vector2,width:float)->VBoxContainer:
	var c:=VBoxContainer.new();c.position=pos;c.custom_minimum_size.x=width;c.add_theme_constant_override("separation",12);parent.add_child(c);return c
func make_ui()->void:
	var canvas:=CanvasLayer.new();canvas.layer=10;add_child(canvas)
	menu=screen(canvas);darken(menu,0.43)
	var intro:=column(menu,Vector2(74,92),470)
	label(intro,"PATAGONIA  /  CHILE",15,Color("d6bc86"))
	label(intro,"FORESTÍN\nAVENTURA",58)
	label(intro,"El camino también se cuida.",23)
	label(intro,"Recorre el sendero. Observa la fauna.\nEncuentra tu lugar entre las montañas.",17)
	if data.stage>0:button(intro,"Continuar recorrido",func():start(true))
	button(intro,"Comenzar aventura",func():start(false))
	var foot:=label(menu,"TORRES DEL PAINE    ·    CUADERNO DE CAMPO Nº 01",13);foot.position=Vector2(74,668)
	hud=screen(canvas);hud.hide()
	var panel:=PanelContainer.new();panel.position=Vector2(26,26);panel.custom_minimum_size=Vector2(390,152);panel.add_theme_stylebox_override("panel",style(Color(0.03,0.085,0.065,0.90)));hud.add_child(panel)
	var content:=VBoxContainer.new();content.add_theme_constant_override("separation",8);panel.add_child(content)
	label(content,"CUADERNO DE CAMPO",12,Color("d6bc86"));objective=label(content,"",21);detail=label(content,"",15);distance_label=label(content,"",13,Color("d6bc86"))
	hint=label(hud,"",21);hint.position=Vector2(250,618);hint.size.x=780;hint.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_shadow_color",Color.BLACK);hint.add_theme_constant_override("shadow_offset_x",2);hint.add_theme_constant_override("shadow_offset_y",2)
	var control_bg:=ColorRect.new();control_bg.color=Color(0.02,0.055,0.04,0.86);control_bg.position=Vector2(0,666);control_bg.size=Vector2(1280,54);control_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.add_child(control_bg)
	var controls:=label(hud,"WASD  Mover    Mouse  Mirar    Shift  Correr    Espacio  Saltar    E  Interactuar    Esc  Pausa",14);controls.position=Vector2(26,680)
	toast_label=label(hud,"",19,Color("f0d291"));toast_label.position=Vector2(440,26);toast_label.size.x=790;toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	pause_ui=screen(canvas);darken(pause_ui,0.78);pause_ui.hide()
	var p:=column(pause_ui,Vector2(430,100),420);label(p,"UN RESPIRO",14,Color("d6bc86"));label(p,"El sendero espera",30)
	button(p,"Volver al recorrido",resume)
	quality_button=button(p,"Calidad: "+quality,cycle_quality)
	night_button=button(p,"Luz: Día / Noche",func():data.night=not data.night;landscape.set_night(data.night);persist())
	button(p,"Sonido: activar / silenciar",func():AudioServer.set_bus_mute(0,not AudioServer.is_bus_mute(0)))
	button(p,"Volver al último checkpoint",func():player.reset_to(point(CHECKPOINTS[data.stage])+Vector3.UP*0.2);resume())
	button(p,"Guardar y salir",func():persist();get_tree().quit())
	ending=screen(canvas);darken(ending,0.72);ending.hide()
	var e:=column(ending,Vector2(350,215),580);label(e,"CUADERNO COMPLETADO",14,Color("d6bc86"));label(e,"Una huella más ligera.",38);label(e,"Observaste sin invadir. Cuidaste el sendero.\nAhora, disfruta el silencio de las Torres.",20)
	button(e,"Seguir explorando",resume);button(e,"Comenzar otro recorrido",func():start(false))
func start(use_save:bool=false)->void:
	if not use_save:data=Progress.fresh();landscape.set_night(false)
	player.reset_to(point(CHECKPOINTS[data.stage])+Vector3.UP*0.2);observed=0;running=true;sync_items();resume();persist();update_hud()
func resume()->void:
	paused=false;menu.hide();pause_ui.hide();ending.hide();hud.show();player.set_active(true)
	for animal in animals:animal.active=true
func pause()->void:
	paused=true;player.set_active(false);pause_ui.show()
	for animal in animals:animal.active=false
func cycle_quality()->void:
	var profiles:Array=Quality.PROFILES.keys();quality=profiles[(profiles.find(quality)+1)%profiles.size()];Quality.apply(quality,get_viewport(),player.camera,landscape.sun);landscape.apply_density(quality);quality_button.text="Calidad: "+quality
func _unhandled_input(event:InputEvent)->void:
	if running and event.is_action_pressed("pause"):
		if paused:resume()
		else:pause()
	if running and not paused and event.is_action_pressed("interact"):interact()
func _process(delta:float)->void:
	if not is_instance_valid(player):return
	if running and not paused:
		if player.position.y< -10 or absf(player.position.x)>42 or player.position.z< -103 or player.position.z>27:player.reset_to(point(CHECKPOINTS[data.stage])+Vector3.UP*0.2)
		observed=minf(observed+delta,2.0) if data.stage==1 and can_observe() else 0.0
		step_timer+=delta*Vector2(player.velocity.x,player.velocity.z).length()
		if step_timer>1.7 and player.is_on_floor():step_timer=0;footsteps.pitch_scale=1+sin(Time.get_ticks_msec()*0.01)*0.06;play_sound(footsteps)
	marker.visible=running and data.stage<4;marker.position=target()+Vector3.UP*(2+sin(Time.get_ticks_msec()*0.002)*0.16)
	toast_time=maxf(0,toast_time-delta)
	if toast_time<=0:toast_label.text=""
	ui_time+=delta
	if ui_time>0.12 and running:ui_time=0;update_hud()
func target()->Vector3:
	match int(data.stage):
		0:return point(Vector2(0,0))
		1:return animals[0].global_position
		2:
			var best:=INF;var result:=point(PICKUPS[0])
			for i in range(3):
				var d:=player.position.distance_squared_to(items[i].position)
				if not data.collected.has(i) and d<best:best=d;result=items[i].position
			return result
		_:return point(Vector2(-8,-82))
func can_observe()->bool:
	for animal in animals:
		var d:=player.position.distance_to(animal.position)
		var anchor:=animal.global_position+Vector3.UP*1.2
		if d<7 or d>19 or player.camera.is_position_behind(anchor):continue
		if (-player.camera.global_basis.z).dot((anchor-player.camera.global_position).normalized())<0.86:continue
		var ray:=PhysicsRayQueryParameters3D.create(player.camera.global_position,anchor,1)
		if get_world_3d().direct_space_state.intersect_ray(ray).is_empty():return true
	return false
func interact()->bool:
	match int(data.stage):
		0:
			if player.position.distance_to(target())>3.5:return false
			advance("Primer descubrimiento registrado")
		1:
			if observed<2 or not can_observe():return false
			advance("Observación registrada · Respetaste su espacio")
		2:
			for i in range(3):
				if not data.collected.has(i) and player.position.distance_to(items[i].position)<2.6:
					data.collected.append(i);sync_items();persist()
					if data.collected.size()==3:advance("Gracias por cuidar el sendero")
					else:toast("Residuo recogido · %d de 3"%data.collected.size());play_sound(chime)
					return true
			return false
		3:
			if player.position.distance_to(target())>4:return false
			advance("Cuaderno de campo completado");paused=true;player.set_active(false);ending.show()
			for animal in animals:animal.active=false
		4:return false
	return true
func advance(message:String)->void:data.stage=mini(data.stage+1,4);persist();toast(message);play_sound(chime);update_hud()
func persist()->void:
	if not no_save and not Progress.save(data):toast("No se pudo guardar el progreso")
func toast(message:String)->void:toast_label.text=message;toast_time=5
func sync_items()->void:
	for i in range(items.size()):items[i].visible=not data.collected.has(i)
func update_hud()->void:
	var distance:=player.position.distance_to(target());var text:=""
	objective.text=["01 · El primer mirador","02 · Un encuentro patagónico","03 · Una huella más ligera","04 · Entre las montañas","Tu cuaderno está completo"][data.stage]
	detail.text=["Lee la señal al comienzo del sendero.","Observa un guanaco desde 7–19 metros.","Recoge los residuos · %d / 3"%data.collected.size(),"Llega a la señal del mirador final.","Puedes seguir explorando el paisaje."][data.stage]
	distance_label.text="%d m  ·  %d de 4 descubrimientos"%[roundi(distance),data.stage]
	if data.stage==0 and distance<3.5:text="E  ·  Leer la señal"
	if data.stage==1:text="E  ·  Registrar observación" if observed>=2 else "Mantén el encuadre…" if observed>0 else "Orienta la cámara hacia un guanaco; respeta su distancia"
	if data.stage==2 and distance<2.6:text="E  ·  Recoger residuo"
	if data.stage==3 and distance<4:text="E  ·  Completar el recorrido"
	hint.text=text
func signpost(pos:Vector2,text:String)->void:
	var n:=Node3D.new();n.position=point(pos);add_child(n);var wood:=Shapes.material(Color("554a33"))
	for x in [-0.55,0.55]:Shapes.box(n,Vector3(x,0.75,0),Vector3(0.09,1.5,0.09),wood)
	Shapes.box(n,Vector3(0,1.25,0),Vector3(1.4,0.50,0.10),wood)
	var l:=Label3D.new();l.text=text;l.font_size=30;l.pixel_size=0.0013;l.position=Vector3(0,1.25,0.06);l.modulate=Color("efe3c3");n.add_child(l)
func setup_audio()->void:
	ambience=AudioStreamPlayer.new();add_child(ambience);var wav:AudioStreamWAV=load("res://adventure/wind.wav");wav.loop_mode=AudioStreamWAV.LOOP_FORWARD;wav.loop_end=int(wav.mix_rate*wav.get_length());ambience.stream=wav;ambience.volume_db=-20
	if DisplayServer.get_name()!="headless" and not OS.get_cmdline_user_args().has("--silent-audio"):ambience.play()
	chime=AudioStreamPlayer.new();add_child(chime);chime.stream=load("res://adventure/chime.wav");chime.volume_db=-17
	footsteps=AudioStreamPlayer.new();add_child(footsteps);footsteps.stream=load("res://adventure/step.wav");footsteps.volume_db=-20

func _exit_tree()->void:
	for audio in [ambience,chime,footsteps]:
		if is_instance_valid(audio):audio.stop();audio.stream=null

func play_sound(sound:AudioStreamPlayer)->void:
	if DisplayServer.get_name()!="headless" and not OS.get_cmdline_user_args().has("--silent-audio"):sound.play()
