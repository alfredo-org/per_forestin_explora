extends Node3D
const Shapes=preload("res://adventure/shapes.gd")
const PATH:=[Vector2(0,14),Vector2(0,0),Vector2(-10,-22),Vector2(-1,-44),Vector2(-3,-61),Vector2(-8,-82)]
var sun:DirectionalLight3D
var environment:Environment
var backdrop_material:StandardMaterial3D
var grass_mesh:MultiMesh
var night:=false
var quality:="HIGH"
static func height_at(x:float,z:float)->float:
	return 0.35*sin(x*0.09)+0.32*cos(z*0.11)+0.002*maxf(-z-45,0)-clampf((x-12)*0.34,0,3.1)
static func trail_distance(x:float,z:float)->float:
	var p:=Vector2(x,z);var best:=10000.0
	for i in range(1,PATH.size()):
		var a:Vector2=PATH[i-1];var b:Vector2=PATH[i]
		var t:=clampf((p-a).dot(b-a)/(b-a).length_squared(),0,1)
		best=minf(best,p.distance_to(a+(b-a)*t))
	return best
func _ready()->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(-105,29,2):
		for x in range(-44,44,2):
			for offset in [Vector2(0,0),Vector2(2,0),Vector2(0,2),Vector2(2,0),Vector2(2,2),Vector2(0,2)]:
				var px:float=x+offset.x;var pz:float=z+offset.y
				var d:=trail_distance(px,pz)
				var terrain:=Color("7a8052").lerp(Color("9b925c"),0.5+0.5*sin(px*0.43)*cos(pz*0.35))
				if d<1.8:terrain=terrain.lerp(Color("b4a27c"),1-smoothstep(0.8,1.8,d))
				st.set_color(terrain);st.set_uv(Vector2(px,pz)*0.06);st.add_vertex(Vector3(px,height_at(px,pz),pz))
	st.generate_normals();var terrain:=MeshInstance3D.new();terrain.name="Terrain";terrain.mesh=st.commit()
	var ground:=Shapes.material(Color.WHITE);ground.vertex_color_use_as_albedo=true;terrain.material_override=ground
	add_child(terrain);terrain.create_trimesh_collision()
	var sky:=ProceduralSkyMaterial.new();sky.sky_top_color=Color("638f9f");sky.sky_horizon_color=Color("d2d1bb");sky.ground_horizon_color=Color("c9c7ad");sky.ground_bottom_color=Color("5c6654")
	environment=Environment.new();environment.background_mode=Environment.BG_SKY;environment.sky=Sky.new();environment.sky.sky_material=sky
	environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;environment.ambient_light_color=Color("c5dbda");environment.ambient_light_energy=0.30
	environment.tonemap_mode=Environment.TONE_MAPPER_FILMIC;environment.fog_enabled=true;environment.fog_density=0.0018;environment.fog_light_color=Color("b3c6c7")
	var world_env:=WorldEnvironment.new();world_env.environment=environment;add_child(world_env)
	sun=DirectionalLight3D.new();sun.name="Sun";sun.rotation_degrees=Vector3(-38,-32,0);sun.light_color=Color("fff0d7");sun.light_energy=0.70;sun.shadow_enabled=true;sun.directional_shadow_max_distance=70;add_child(sun)
	var water:=MeshInstance3D.new();var plane:=PlaneMesh.new();plane.size=Vector2(50,140);water.mesh=plane;water.position=Vector3(38,-0.25,-40)
	var shader:=Shader.new();shader.code="shader_type spatial; render_mode cull_disabled; void fragment(){ vec2 q=UV*90.; float w=sin(q.x+TIME*.7)*sin(q.y*.7+TIME*.4); ALBEDO=mix(vec3(.035,.24,.25),vec3(.14,.46,.44),.5+w*.18); ROUGHNESS=.25; METALLIC=.25; NORMAL=normalize(vec3(w*.07,.04*cos(q.x+TIME),1.)); }"
	var wm:=ShaderMaterial.new();wm.shader=shader;water.material_override=wm;add_child(water)
	var backdrop:=MeshInstance3D.new();var quad:=QuadMesh.new();quad.size=Vector2(140,93);backdrop.mesh=quad;backdrop.position=Vector3(-2,27,-170)
	var bm:=Shapes.material(Color.WHITE);bm.albedo_texture=load("res://assets/environment/torres.png");bm.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;bm.alpha_scissor_threshold=0.08;bm.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;bm.cull_mode=BaseMaterial3D.CULL_DISABLED;backdrop_material=bm;backdrop.material_override=bm;backdrop.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(backdrop)
	var rng:=RandomNumberGenerator.new();rng.seed=381
	var rockmat:=Shapes.material(Color("858b80"))
	for i in range(105):
		var x:=rng.randf_range(-39,36);var z:=rng.randf_range(-96,22)
		if trail_distance(x,z)<3 or x>12:continue
		var size:=rng.randf_range(0.35,1.6)
		var rock:=Shapes.ellipsoid(self,Vector3(x,height_at(x,z)+size*0.22,z),Vector3(size*1.6,size,size*1.3),rockmat);rock.rotation_degrees=Vector3(rng.randf_range(-20,20),rng.randf_range(0,360),rng.randf_range(-10,10))
		if size>0.8:rock.create_convex_collision()
	for i in range(38):
		var x:=rng.randf_range(-39,6);var z:=rng.randf_range(-95,22)
		if trail_distance(x,z)<5:continue
		var scale_tree:=rng.randf_range(0.75,1.4)
		var base:=Vector3(x,height_at(x,z),z)
		Shapes.capsule(self,base+Vector3.UP*1.5*scale_tree,0.13*scale_tree,3.0*scale_tree,Shapes.material(Color("5e5943")))
		for j in range(3):
			var leaf:=Shapes.ellipsoid(self,base+Vector3(rng.randf_range(-0.8,0.8),2.7+j*0.5,rng.randf_range(-0.6,0.6))*scale_tree,Vector3(2.4,1.6,2.3)*scale_tree,Shapes.material(Color("4d6240").lerp(Color("7d8143"),rng.randf())))
			leaf.rotation.y=rng.randf()*TAU
	var grass:=SurfaceTool.new();grass.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(3):
		var angle:=float(i)*TAU/3
		for vertex in [Vector3(-0.09,0,0),Vector3(0.02,0.55,0.10),Vector3(0.09,0,0)]:grass.add_vertex(vertex.rotated(Vector3.UP,angle))
	grass.generate_normals()
	var blades:=MultiMesh.new();blades.transform_format=MultiMesh.TRANSFORM_3D;blades.mesh=grass.commit();blades.instance_count=1400
	for i in range(blades.instance_count):
		var x:=rng.randf_range(-40,10);var z:=rng.randf_range(-98,24)
		if trail_distance(x,z)<2:x-=3.5
		var transform:=Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(0.6,1.4)),Vector3(x,height_at(x,z),z));blades.set_instance_transform(i,transform)
	var grassnode:=MultiMeshInstance3D.new();grassnode.multimesh=blades;grass_mesh=blades
	var gs:=Shader.new();gs.code="shader_type spatial; render_mode cull_disabled; void vertex(){VERTEX.x+=sin(TIME*1.4+MODEL_MATRIX[3].x*.4+MODEL_MATRIX[3].z*.2)*VERTEX.y*.15;} void fragment(){ALBEDO=vec3(.42,.46,.25);ROUGHNESS=1.;}"
	var gm:=ShaderMaterial.new();gm.shader=gs;grassnode.material_override=gm;grassnode.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(grassnode)
func set_night(value:bool)->void:
	night=value
	backdrop_material.albedo_color=Color("435978") if value else Color.WHITE
	environment.fog_light_color=Color("243247") if value else Color("b3c6c7")
	sun.light_energy=0.20 if value else 0.70;sun.light_color=Color("b1c5ef") if value else Color("fff0d7")
	environment.ambient_light_energy=0.24 if value else 0.30
	var sky:ProceduralSkyMaterial=environment.sky.sky_material
	sky.sky_top_color=Color("09172e") if value else Color("638f9f");sky.sky_horizon_color=Color("31455e") if value else Color("d2d1bb")

func apply_density(profile:String)->void:
	grass_mesh.visible_instance_count=mini(420 if profile in ["LOW","MOBILE"] else 1400,grass_mesh.instance_count)
