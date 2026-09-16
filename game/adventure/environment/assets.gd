extends RefCounted
## Deterministic scene geometry: one batched wood surface and one instanced leaf draw per tree.
const Shapes=preload("res://adventure/shapes.gd")
static func branch(parent:Node3D,a:Vector3,b:Vector3,radius:float,mat:Material)->void:
	# Curved taper gives trunks an organic silhouette without separate cylinder joints.
	var up:=(b-a).normalized()
	var tangent:=Vector3.RIGHT.cross(up).normalized()
	if tangent.length()<.01:tangent=Vector3.FORWARD
	var side:=up.cross(tangent).normalized()
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var vertices:=PackedVector3Array();var normals:=PackedVector3Array()
	for ring in range(6):
		var t:=float(ring)/5.0
		var center:=a.lerp(b,t)+side*sin(t*PI)*radius*.8
		var width:=radius*lerpf(1.0,.32,t)*(1.0+.09*sin(t*9.0))
		for spoke in range(12):
			var angle:=float(spoke)/12.0*TAU
			var normal:=side*cos(angle)+tangent*sin(angle)
			vertices.append(center+normal*width*(1.0+.055*sin(angle*5.0+t*3.0)))
			normals.append(normal)
	for ring in range(5):
		for spoke in range(12):
			var next:=(spoke+1)%12
			for index in [ring*12+spoke,ring*12+next,(ring+1)*12+spoke,ring*12+next,(ring+1)*12+next,(ring+1)*12+spoke]:
				st.set_normal(normals[index]);st.set_uv(Vector2(float(index%12)/12.0,float(index/12)/5.0));st.add_vertex(vertices[index])
	var node:=MeshInstance3D.new();node.mesh=st.commit();node.material_override=mat;parent.add_child(node)
static func rock_mesh(seed_value:int)->ArrayMesh:
	var sphere:=SphereMesh.new();sphere.radial_segments=32;sphere.rings=18;sphere.radius=.5;sphere.height=1
	var arrays:=sphere.get_mesh_arrays();var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals:PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var noise:=FastNoiseLite.new();noise.seed=seed_value;noise.frequency=3.1
	noise.fractal_octaves=3;noise.fractal_gain=.42
	for i in range(vertices.size()):
		var p:=vertices[i]
		var radial:=p.normalized()
		var tangent:=radial.cross(Vector3.UP).normalized()
		if tangent.length()<.01:tangent=Vector3.RIGHT
		var bitangent:=radial.cross(tangent).normalized()
		var epsilon:=.002
		var center:=p*(1.0+noise.get_noise_3dv(p)*.48)
		var pu:=(p+tangent*epsilon).normalized()*.5
		var pv:=(p+bitangent*epsilon).normalized()*.5
		var du:=pu*(1.0+noise.get_noise_3dv(pu)*.48)-center
		var dv:=pv*(1.0+noise.get_noise_3dv(pv)*.48)-center
		vertices[i]=center
		normals[i]=du.cross(dv).normalized()
	arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals
	# Recomputed continuous normals agree across the sphere UV seam and poles.
	arrays[Mesh.ARRAY_TANGENT]=null
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	return mesh
static func leaf_mesh()->ArrayMesh:
	# Rounded, gently cupped blade: real silhouette geometry, no alpha cards or diamonds.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outline:=PackedVector3Array()
	for i in range(16):
		var angle:=float(i)/16.0*TAU
		outline.append(Vector3(sin(angle)*.115,.007+.016*cos(angle),cos(angle)*.18))
	for i in range(16):
		for p in [Vector3(0,.025,0),outline[(i+1)%16],outline[i]]:
			var point:Vector3=p
			st.set_normal(Vector3(point.x*.8,1.0,point.z*.2).normalized())
			st.set_uv(Vector2(point.x/.23+.5,point.z/.36+.5));st.add_vertex(point)
	return st.commit()
static func tree(parent:Node3D,base:Vector3,size:float,seed_value:int,leaf:Mesh,leaf_material:Material,bark:Material)->MultiMesh:
	var root:=Node3D.new();root.position=base;root.scale=Vector3.ONE*size;parent.add_child(root)
	var rng:=RandomNumberGenerator.new();rng.seed=seed_value
	branch(root,Vector3.ZERO,Vector3(.12,3.8,.07),.17,bark)
	var clusters:Array[Vector3]=[]
	for j in range(9):
		var angle:=j*2.4+rng.randf_range(-.3,.3)
		var start:=Vector3(.04,1.5+j*.24,0)
		var endpoint:=Vector3(cos(angle)*(1.1-j*.06),start.y+.8,sin(angle)*(1.1-j*.06))
		branch(root,start,endpoint,.065-j*.004,bark)
		branch(root,endpoint,endpoint+Vector3(.2,.45,-.12),.022,bark)
		clusters.append(endpoint+Vector3(0,.3,0))
	var wood:=SurfaceTool.new();wood.begin(Mesh.PRIMITIVE_TRIANGLES)
	for child in root.get_children():
		if child is MeshInstance3D:
			wood.append_from(child.mesh,0,child.transform)
			child.free()
	var trunk:=MeshInstance3D.new();trunk.mesh=wood.commit();trunk.material_override=bark;root.add_child(trunk)
	var leaves:=MultiMesh.new();leaves.transform_format=MultiMesh.TRANSFORM_3D;leaves.use_colors=true;leaves.mesh=leaf;leaves.instance_count=810
	for i in range(leaves.instance_count):
		# Interleaved clusters keep the low-quality prefix evenly distributed through the crown.
		var center:=clusters[i%clusters.size()]
		var direction:=Vector3(rng.randf_range(-1,1),rng.randf_range(-.6,.8),rng.randf_range(-1,1)).normalized()
		var p:=center+direction*pow(rng.randf(),.333)*.78
		var b:=Basis.from_euler(Vector3(rng.randf_range(-.75,.75),rng.randf()*TAU,rng.randf_range(-.65,.65)))
		leaves.set_instance_transform(i,Transform3D(b.scaled(Vector3.ONE*rng.randf_range(.9,1.65)),p))
		var tint:=Color("365334").lerp(Color("7a914b"),clampf((p.y-1.8)/3.4+rng.randf_range(-.2,.2),0,1))
		leaves.set_instance_color(i,tint)
	var instanced:=MultiMeshInstance3D.new();instanced.multimesh=leaves;instanced.material_override=leaf_material;root.add_child(instanced)
	return leaves
