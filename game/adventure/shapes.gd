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
	var root := Node3D.new()
	root.name = "Forestin"
	var fur := material(Color("9d693b"))
	var face := material(Color("bf925a"))
	var khaki := material(Color("b0a17a"))
	var green := material(Color("315b35"),0.42)
	var boots := material(Color("352e25"))
	var eye := material(Color("101712"),0.12)
	var cream := material(Color("e7dbc0"))
	ellipsoid(root,Vector3(0,0.99,0),Vector3(0.6,0.77,0.43),khaki)
	ellipsoid(root,Vector3(0,0.74,0.015),Vector3(0.48,0.35,0.36),boots)
	box(root,Vector3(0,0.81,-0.22),Vector3(0.51,0.065,0.08),boots)
	box(root,Vector3(0,0.81,-0.27),Vector3(0.08,0.07,0.025),cream)
	for side in [-1,1]:
		var leg := pivot(root,Vector3(side*0.15,0.74,0),"LegL" if side<0 else "LegR")
		capsule(leg,Vector3(0,-0.23,0),0.12,0.48,boots)
		ellipsoid(leg,Vector3(0,-0.61,-0.055),Vector3(0.26,0.23,0.43),boots)
		var arm := pivot(root,Vector3(side*0.32,1.19,0),"ArmL" if side<0 else "ArmR")
		capsule(arm,Vector3(side*0.035,-0.19,0),0.105,0.43,khaki)
		ellipsoid(arm,Vector3(side*0.055,-0.42,-0.025),Vector3(0.18,0.22,0.17),cream)
		box(root,Vector3(side*0.145,1.11,-0.205),Vector3(0.15,0.17,0.045),green)
		box(root,Vector3(side*0.225,1.12,-0.205),Vector3(0.04,0.46,0.055),boots)
	var head := pivot(root,Vector3(0,1.43,-0.035),"Head")
	ellipsoid(head,Vector3.ZERO,Vector3(0.7,0.61,0.56),fur)
	for side in [-1,1]:
		ellipsoid(head,Vector3(side*0.2,-0.08,-0.19),Vector3(0.34,0.30,0.34),face)
		ellipsoid(head,Vector3(side*0.32,0.17,0.015),Vector3(0.20,0.22,0.10),fur)
		ellipsoid(head,Vector3(side*0.325,0.17,-0.035),Vector3(0.105,0.13,0.035),face)
		ellipsoid(head,Vector3(side*0.18,0.075,-0.25),Vector3(0.085,0.10,0.06),eye)
		ellipsoid(head,Vector3(side*0.166,0.095,-0.279),Vector3(0.022,0.025,0.01),cream)
		for j in range(3):
			var whisker := capsule(head,Vector3(side*0.31,-0.075-j*0.025,-0.30),0.004,0.19,cream)
			whisker.rotation.z = side*(1.25+j*0.16)
	ellipsoid(head,Vector3(0,-0.055,-0.365),Vector3(0.21,0.12,0.10),eye)
	box(head,Vector3(0,-0.23,-0.285),Vector3(0.105,0.105,0.028),cream)
	ellipsoid(head,Vector3(0,0.22,0.015),Vector3(0.73,0.35,0.63),green)
	ellipsoid(head,Vector3(0,0.155,-0.22),Vector3(0.78,0.055,0.52),green)
	box(head,Vector3(0,0.235,-0.301),Vector3(0.17,0.10,0.035),cream)
	ellipsoid(root,Vector3(0,1.05,0.28),Vector3(0.46,0.57,0.23),green)
	return root
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
	var tail:=capsule(root,Vector3(0,1.27,0.59),0.06,0.39,coat)
	tail.rotation.x=1.0
	return root
