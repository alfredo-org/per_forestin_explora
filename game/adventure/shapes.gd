extends RefCounted
static func material(color: Color, rough: float = 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	return m
static func ellipsoid(parent: Node3D, position: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 16
	mesh.rings = 8
	n.mesh = mesh
	n.position = position
	n.scale = size
	n.material_override = mat
	parent.add_child(n)
	return n
static func box(parent: Node3D, position: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = position
	n.material_override = mat
	parent.add_child(n)
	return n
static func capsule(parent: Node3D, position: Vector3, radius: float, height: float, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 4
	n.mesh = mesh
	n.position = position
	n.material_override = mat
	parent.add_child(n)
	return n
static func pivot(parent: Node3D, position: Vector3, name: String) -> Node3D:
	var n := Node3D.new()
	n.name = name
	n.position = position
	parent.add_child(n)
	return n
static func forestin() -> Node3D:
	return preload("res://adventure/forestin_model.gd").build()
static func guanaco() -> Node3D:
	var root := Node3D.new()
	var coat := material(Color("b6844f"))
	var pale := material(Color("ddd0b2"))
	var dark := material(Color("3c3026"))
	var black := material(Color("121712"),0.15)
	ellipsoid(root,Vector3(0,1.12,0),Vector3(0.62,0.77,1.05),coat)
	ellipsoid(root,Vector3(0,0.97,-0.10),Vector3(0.49,0.40,0.79),pale)
	for i in range(4):
		var leg := pivot(root,Vector3(-0.2 if i%2==0 else 0.2,1.0,-0.34 if i<2 else 0.34),"Leg%d"%i)
		capsule(leg,Vector3(0,-0.37,0),0.065,0.82,coat)
		ellipsoid(leg,Vector3(0,-0.9,-0.03),Vector3(0.14,0.15,0.21),dark)
	var neck := pivot(root,Vector3(0,1.22,-0.41),"Neck")
	var tube := ellipsoid(neck,Vector3(0,0.49,-0.16),Vector3(0.29,1.22,0.30),coat)
	tube.rotation.x = -0.2
	ellipsoid(neck,Vector3(0,0.90,-0.34),Vector3(0.31,0.33,0.47),coat)
	ellipsoid(neck,Vector3(0,0.85,-0.52),Vector3(0.23,0.19,0.30),pale)
	ellipsoid(neck,Vector3(0,0.87,-0.67),Vector3(0.18,0.10,0.07),dark)
	for side in [-1,1]:
		var ear:=ellipsoid(neck,Vector3(side*0.12,1.19,-0.22),Vector3(0.09,0.40,0.11),coat)
		ear.rotation.z=side*-0.16
		ellipsoid(neck,Vector3(side*0.152,0.97,-0.43),Vector3(0.035,0.06,0.05),black)
		var inner:=ellipsoid(neck,Vector3(side*.12,1.20,-.273),Vector3(.045,.27,.018),pale)
		inner.rotation.z=side*-.16
		ellipsoid(neck,Vector3(side*.073,.88,-.704),Vector3(.027,.023,.016),black)
	fur_patch(root,Vector3(0,1.12,0),Vector3(.31,.385,.525),Color("a67b49"),1000,119)
	var tail:=capsule(root,Vector3(0,1.27,0.59),0.06,0.39,coat)
	tail.rotation.x=1.0
	return root

static func fur_patch(parent:Node3D,center:Vector3,radii:Vector3,color:Color,count:int,seed_value:int)->void:
	# Short, opaque fibers; one draw per patch and deterministic distribution.
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for v in [Vector3(-.003,0,0),Vector3(0,.022,0),Vector3(.003,0,0),Vector3(0,0,-.003),Vector3(0,.022,0),Vector3(0,0,.003)]:st.add_vertex(v)
	st.generate_normals()
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=st.commit();mm.instance_count=count
	var rng:=RandomNumberGenerator.new();rng.seed=seed_value
	for i in range(count):
		var direction:=Vector3(rng.randf_range(-1,1),rng.randf_range(-1,1),rng.randf_range(-1,1)).normalized()
		var normal:=(direction/radii).normalized()
		var tangent:=Vector3.RIGHT.cross(normal).normalized()
		if tangent.length()<.01:tangent=Vector3.FORWARD
		var b:=Basis(normal.cross(tangent).normalized(),normal,tangent)
		mm.set_instance_transform(i,Transform3D(b.scaled(Vector3.ONE*rng.randf_range(.65,1.1)),center+direction*radii))
		mm.set_instance_color(i,color.lerp(color.darkened(.26),rng.randf()))
	var node:=MultiMeshInstance3D.new();node.multimesh=mm
	var mat:=material(Color.WHITE);mat.vertex_color_use_as_albedo=true;mat.cull_mode=BaseMaterial3D.CULL_DISABLED
	node.material_override=mat;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(node)
