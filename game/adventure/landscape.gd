extends Node3D
const Assets=preload("res://adventure/environment/assets.gd")
const Shapes=preload("res://adventure/shapes.gd")
const PATH:=[Vector2(0,14),Vector2(0,0),Vector2(-10,-22),Vector2(-1,-44),Vector2(-3,-61),Vector2(-8,-82)]
var sun:DirectionalLight3D
var environment:Environment
var backdrop_material:ShaderMaterial
var leaf_multimeshes:Array[MultiMesh]=[]
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
	for z in range(-155,73,2):
		for x in range(-100,100,2):
			for offset in [Vector2(0,0),Vector2(2,0),Vector2(0,2),Vector2(2,0),Vector2(2,2),Vector2(0,2)]:
				var px:float=x+offset.x;var pz:float=z+offset.y
				var d:=trail_distance(px,pz)
				var terrain:=Color("7a8052").lerp(Color("9b925c"),0.5+0.5*sin(px*0.43)*cos(pz*0.35))
				if d<1.8:terrain=terrain.lerp(Color("b4a27c"),1-smoothstep(0.8,1.8,d))
				st.set_color(terrain);st.set_uv(Vector2(px,pz)*0.06);st.set_uv2(Vector2(d,0));st.add_vertex(Vector3(px,height_at(px,pz),pz))
	st.generate_normals();var terrain:=MeshInstance3D.new();terrain.name="Terrain";terrain.mesh=st.commit()
	var ground:=ShaderMaterial.new();ground.shader=preload("res://adventure/environment/ground.gdshader");terrain.material_override=ground
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
	backdrop_material=ShaderMaterial.new();backdrop_material.shader=preload("res://adventure/environment/backdrop.gdshader")
	backdrop_material.set_shader_parameter("landscape_texture",load("res://assets/environment/torres.png"))
	backdrop.material_override=backdrop_material;backdrop.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(backdrop)
	build_ridges()
	var rng:=RandomNumberGenerator.new();rng.seed=381
	var rockmat:=Shapes.material(Color("65695f"))
	var rock_shapes:Array[ArrayMesh]=[]
	for i in range(7):rock_shapes.append(Assets.rock_mesh(100+i))
	for i in range(105):
		var x:=rng.randf_range(-39,36);var z:=rng.randf_range(-96,22)
		if trail_distance(x,z)<3 or x>12:continue
		var size:=rng.randf_range(0.35,1.6)
		var rock:=MeshInstance3D.new();rock.mesh=rock_shapes[i%rock_shapes.size()];rock.material_override=rockmat;rock.position=Vector3(x,height_at(x,z)+size*0.22,z);rock.scale=Vector3(size*1.6,size,size*1.3);add_child(rock);rock.rotation_degrees=Vector3(rng.randf_range(-20,20),rng.randf_range(0,360),rng.randf_range(-10,10))
		if size>0.8:rock.create_convex_collision()
	var leaf:=Assets.leaf_mesh()
	var leaf_material:=ShaderMaterial.new();leaf_material.shader=preload("res://adventure/environment/leaves.gdshader")
	var bark:=Shapes.material(Color("413c2e"))
	for i in range(38):
		var x:=rng.randf_range(-39,6);var z:=rng.randf_range(-95,22)
		if trail_distance(x,z)<5:continue
		leaf_multimeshes.append(Assets.tree(self,Vector3(x,height_at(x,z),z),rng.randf_range(.85,1.35),i+97,leaf,leaf_material,bark))
	var grass:=SurfaceTool.new();grass.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(8):
		var angle:=float(i)*2.4;var h:=.22+float(i%4)*.075
		var bend:=Vector3(sin(angle)*.13,0,cos(angle)*.13)
		var base:=Vector3(cos(angle)*.065,0,sin(angle)*.065)
		var side:=Vector3(cos(angle),0,sin(angle))*.018
		var middle:=base+Vector3.UP*h*.55+bend*.35
		var tip:=base+Vector3.UP*h+bend
		for vertex in [base-side,middle-side*.6,base+side,base+side,middle-side*.6,middle+side*.6,middle-side*.6,tip,middle+side*.6]:grass.add_vertex(vertex)
	grass.generate_normals()
	var blades:=MultiMesh.new();blades.transform_format=MultiMesh.TRANSFORM_3D;blades.mesh=grass.commit();blades.instance_count=1400
	for i in range(blades.instance_count):
		var x:=rng.randf_range(-40,10);var z:=rng.randf_range(-98,24)
		while trail_distance(x,z)<2:
			x=rng.randf_range(-40,10);z=rng.randf_range(-98,24)
		var transform:=Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3.ONE*rng.randf_range(0.6,1.4)),Vector3(x,height_at(x,z),z));blades.set_instance_transform(i,transform)
	var grassnode:=MultiMeshInstance3D.new();grassnode.multimesh=blades;grass_mesh=blades
	var gs:=Shader.new();gs.code="shader_type spatial; render_mode cull_disabled; void vertex(){VERTEX.x+=sin(TIME*1.4+MODEL_MATRIX[3].x*.4+MODEL_MATRIX[3].z*.2)*VERTEX.y*.15;} void fragment(){ALBEDO=vec3(.16,.20,.075);ROUGHNESS=1.;}"
	var gm:=ShaderMaterial.new();gm.shader=gs;grassnode.material_override=gm;grassnode.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(grassnode)
func set_night(value:bool)->void:
	night=value
	backdrop_material.set_shader_parameter("tint",Color("435978") if value else Color("c4ced1"))
	environment.fog_light_color=Color("243247") if value else Color("b3c6c7")
	sun.light_energy=0.20 if value else 0.70;sun.light_color=Color("b1c5ef") if value else Color("fff0d7")
	environment.ambient_light_energy=0.24 if value else 0.30
	var sky:ProceduralSkyMaterial=environment.sky.sky_material
	sky.sky_top_color=Color("09172e") if value else Color("638f9f");sky.sky_horizon_color=Color("31455e") if value else Color("d2d1bb")

func apply_density(profile:String)->void:
	grass_mesh.visible_instance_count=mini(420 if profile in ["LOW","MOBILE"] else 1400,grass_mesh.instance_count)

	for leaves in leaf_multimeshes:leaves.visible_instance_count=405 if profile in ["LOW","MOBILE"] else 810

func build_ridges()->void:
	# Distant scenery surrounds the playable corridor and covers the flat backdrop base.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var noise:=FastNoiseLite.new();noise.seed=502;noise.frequency=.055
	var center:=Vector3(0,0,-37)
	for i in range(96):
		var a:=float(i)*TAU/96;var b:=float(i+1)*TAU/96
		var columns:Array[Vector3]=[]
		for angle in [a,b]:
			var direction:=Vector3(sin(angle),0,cos(angle))
			var peak:=7.0+absf(noise.get_noise_2d(direction.x*100,direction.z*100))*20
			if direction.z<-.7:peak*=.45
			columns.append(center+direction*78+Vector3.DOWN*3)
			columns.append(center+direction*118+Vector3.UP*peak)
			columns.append(center+direction*170+Vector3.DOWN*5)
		for index in [0,3,1,1,3,4,1,4,2,2,4,5]:
			var v:Vector3=columns[index]
			st.set_color(Color("525e58").lerp(Color("9a9c8b"),clampf(v.y/35,0,1)));st.add_vertex(v)
	st.generate_normals()
	var node:=MeshInstance3D.new();node.name="DistantRidges";node.mesh=st.commit()
	var mat:=ShaderMaterial.new();mat.shader=preload("res://adventure/environment/ridge.gdshader")
	node.material_override=mat;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(node)
