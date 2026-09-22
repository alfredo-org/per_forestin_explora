extends RefCounted
## Authored procedural skyline, inspired by the three granite towers.
## All geometry is volumetric; no billboard, alpha edge or generated texture.
static func radius_at(t:float)->float:
	var profile:=[Vector2(0,1),Vector2(.12,.85),Vector2(.25,.53),Vector2(.40,.43),Vector2(.65,.40),Vector2(.82,.32),Vector2(.93,.18),Vector2(1,.008)]
	for i in range(profile.size()-1):
		if t<=profile[i+1].x:
			var f:float=inverse_lerp(profile[i].x,profile[i+1].x,t)
			return lerpf(profile[i].y,profile[i+1].y,f)
	return .008
static func point(angle:float,t:float,width:float,height:float,seed_value:int,noise:FastNoiseLite)->Vector3:
	var radial:=radius_at(t)
	var ribs:=1.0+.09*sin(angle*5+float(seed_value))+.045*sin(angle*11+t*3)
	var rock:=noise.get_noise_3d(cos(angle)*13,t*35,sin(angle)*13)
	var r:=width*radial*ribs*(1.0+rock*.16)
	return Vector3(cos(angle)*r+sin(t*2.0)*width*.09,t*height-4.0,sin(angle)*r*.77+sin(t*3.0)*width*.07)
static func build(parent:Node3D)->void:
	var material:=ShaderMaterial.new();material.shader=preload("res://adventure/environment/granite.gdshader")
	# Broad scree shoulders overlap at the base; the pinnacles remain distinct.
	var specs:=[Vector4(-25,-184,21,64),Vector4(-3,-190,23,83),Vector4(21,-181,20,70)]
	for k in range(specs.size()):
		var spec:Vector4=specs[k]
		var noise:=FastNoiseLite.new();noise.seed=731+k*17;noise.frequency=.35;noise.fractal_octaves=3
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);st.set_smooth_group(0)
		var segments:=96;var rings:=80
		for j in range(rings):
			for i in range(segments):
				var a:=point(TAU*float(i)/segments,float(j)/rings,spec.z,spec.w,k,noise)
				var b:=point(TAU*float((i+1)%segments)/segments,float(j)/rings,spec.z,spec.w,k,noise)
				var c:=point(TAU*float(i)/segments,float(j+1)/rings,spec.z,spec.w,k,noise)
				var d:=point(TAU*float((i+1)%segments)/segments,float(j+1)/rings,spec.z,spec.w,k,noise)
				for v in [a,b,c,b,d,c]:st.add_vertex(v)
		st.index();st.generate_normals()
		var tower:=MeshInstance3D.new();tower.name="GraniteTower"+str(k+1);tower.mesh=st.commit();tower.material_override=material
		tower.position=Vector3(spec.x,0,spec.y);parent.add_child(tower)
	# Foothills provide a continuous foreground silhouette beneath the towers.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);st.set_smooth_group(0)
	var noise:=FastNoiseLite.new();noise.seed=809;noise.frequency=.065
	for z in range(-226,-128,2):
		for x in range(-76,72,2):
			for p in [Vector2(x,z),Vector2(x+2,z),Vector2(x,z+2),Vector2(x+2,z),Vector2(x+2,z+2),Vector2(x,z+2)]:
				var envelope:=maxf(0,1.0-pow((p.x+2)/76.0,2))*maxf(0,1.0-pow((p.y+177)/50.0,2))
				var y:=-4+envelope*(15+noise.get_noise_2dv(p)*9)
				st.add_vertex(Vector3(p.x,y,p.y))
	st.index();st.generate_normals()
	var apron:=MeshInstance3D.new();apron.name="TorresScree";apron.mesh=st.commit();apron.material_override=material;parent.add_child(apron)
