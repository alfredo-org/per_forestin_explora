extends RefCounted
## Deterministic scene geometry: no downloaded assets, one instanced leaf draw per tree.
const Shapes=preload("res://adventure/shapes.gd")
static func branch(parent:Node3D,a:Vector3,b:Vector3,radius:float,mat:Material)->void:
	var mesh:=CylinderMesh.new()
	mesh.top_radius=radius*.48;mesh.bottom_radius=radius;mesh.height=a.distance_to(b);mesh.radial_segments=7
	var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=mat;parent.add_child(node)
	node.position=(a+b)*.5
	var up:=(b-a).normalized();var tangent:=Vector3.RIGHT.cross(up).normalized()
	if tangent.length()<.01:tangent=Vector3.FORWARD
	node.basis=Basis(up.cross(tangent).normalized(),up,tangent)
static func rock_mesh(seed_value:int)->ArrayMesh:
	var sphere:=SphereMesh.new();sphere.radial_segments=14;sphere.rings=9;sphere.radius=.5;sphere.height=1
	var arrays:=sphere.get_mesh_arrays();var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var noise:=FastNoiseLite.new();noise.seed=seed_value;noise.frequency=4.0
	for i in range(vertices.size()):
		var p:=vertices[i];var n:=noise.get_noise_3dv(p)
		vertices[i]=p*(1.0+n*.4)
	arrays[Mesh.ARRAY_VERTEX]=vertices
	var raw:=ArrayMesh.new();raw.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var st:=SurfaceTool.new();st.create_from(raw,0);st.generate_normals()
	return st.commit()
static func leaf_mesh()->ArrayMesh:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var points:=[Vector3(0,0,-.11),Vector3(-.075,0,0),Vector3(0,.026,0),Vector3(.075,0,0),Vector3(0,0,.11)]
	for index in [0,2,1,0,3,2,1,2,4,2,3,4]:
		var p:Vector3=points[index];st.set_uv(Vector2(p.x/.15+.5,p.z/.22+.5));st.add_vertex(p)
	st.generate_normals();return st.commit()
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
	var leaves:=MultiMesh.new();leaves.transform_format=MultiMesh.TRANSFORM_3D;leaves.use_colors=true;leaves.mesh=leaf;leaves.instance_count=810
	for i in range(leaves.instance_count):
		var center:=clusters[i%clusters.size()]
		var direction:=Vector3(rng.randf_range(-1,1),rng.randf_range(-.6,.8),rng.randf_range(-1,1)).normalized()
		var p:=center+direction*pow(rng.randf(),.333)*.88
		var b:=Basis.from_euler(Vector3(rng.randf_range(-.9,.9),rng.randf()*TAU,rng.randf_range(-.7,.7)))
		leaves.set_instance_transform(i,Transform3D(b.scaled(Vector3.ONE*rng.randf_range(.75,1.5)),p))
		leaves.set_instance_color(i,Color("344c24").lerp(Color("85844d"),rng.randf()))
	var instanced:=MultiMeshInstance3D.new();instanced.multimesh=leaves;instanced.material_override=leaf_material;root.add_child(instanced)
	return leaves
