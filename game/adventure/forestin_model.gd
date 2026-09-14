extends RefCounted
## Forestin reference costume and face, constructed entirely from native 3D geometry.
static func mat(hex:String,rough:float=.7)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=Color(hex);m.roughness=rough;return m
static func node(p:Node3D,pos:Vector3,name:String)->Node3D:
	var n:=Node3D.new();n.name=name;n.position=pos;p.add_child(n);return n
static func oval(p:Node3D,pos:Vector3,size:Vector3,m:Material)->MeshInstance3D:
	var n:=MeshInstance3D.new();var s:=SphereMesh.new();s.radius=.5;s.height=1;s.radial_segments=32;s.rings=16
	n.mesh=s;n.position=pos;n.scale=size;n.material_override=m;p.add_child(n);return n
static func block(p:Node3D,pos:Vector3,size:Vector3,m:Material)->MeshInstance3D:
	var n:=MeshInstance3D.new();var s:=BoxMesh.new();s.size=size;n.mesh=s;n.position=pos;n.material_override=m;p.add_child(n);return n
static func line(p:Node3D,a:Vector3,b:Vector3,r:float,m:Material)->void:
	var n:=MeshInstance3D.new();var s:=CylinderMesh.new();s.top_radius=r;s.bottom_radius=r;s.height=a.distance_to(b);s.radial_segments=8
	n.mesh=s;n.position=(a+b)*.5;n.quaternion=Quaternion(Vector3.UP,(b-a).normalized());n.material_override=m;p.add_child(n)
static func text3(p:Node3D,pos:Vector3,value:String,size:float,color:Color)->void:
	var t:=Label3D.new();t.text=value;t.font_size=64;t.pixel_size=size;t.position=pos;t.rotation.y=PI;t.modulate=color;t.outline_size=0;t.no_depth_test=false;p.add_child(t)
static func build()->Node3D:
	var root:=Node3D.new();root.name="Forestin"
	var fur:=mat("e98122");var inner:=mat("bc5017");var muzzle:=mat("ffe0a0")
	var green:=mat("006344");var seam:=mat("004631");var yellow:=mat("ffca19")
	var white:=mat("fff9ed",.35);var gold:=mat("edb650",.3);var leather:=mat("a94d21",.5);var sole:=mat("d68035")
	var dark:=mat("29140c",.35);var mouth:=mat("40110f");var tongue:=mat("e85459");var iris:=mat("934211",.25)
	# Rounded work shirt and overalls. Front of the character is -Z.
	oval(root,Vector3(0,1.04,0),Vector3(.61,.70,.43),yellow)
	oval(root,Vector3(0,.83,.015),Vector3(.58,.39,.43),green)
	oval(root,Vector3(0,1.0,-.183),Vector3(.51,.43,.13),green)
	block(root,Vector3(0,.94,-.249),Vector3(.29,.20,.025),seam)
	oval(root,Vector3(0,.94,-.268),Vector3(.28,.21,.035),green)
	text3(root,Vector3(0,.95,-.289),"CONAF",.00062,Color.WHITE)
	for side in [-1,1]:
		block(root,Vector3(side*.215,1.17,-.20),Vector3(.075,.34,.045),green)
		block(root,Vector3(side*.215,1.195,-.229),Vector3(.092,.061,.022),gold)
		block(root,Vector3(side*.215,1.195,-.244),Vector3(.065,.032,.008),green)
		oval(root,Vector3(side*.205,1.08,-.25),Vector3(.051,.051,.022),gold)
		var collar:=block(root,Vector3(side*.085,1.31,-.20),Vector3(.13,.095,.05),yellow);collar.rotation.z=side*.40
		var leg:=node(root,Vector3(side*.16,.74,0),"LegL" if side<0 else "LegR")
		oval(leg,Vector3(0,-.14,0),Vector3(.27,.39,.29),green)
		var knee:=node(leg,Vector3(0,-.32,0),"Knee")
		oval(knee,Vector3(0,-.12,0),Vector3(.245,.37,.255),green)
		oval(knee,Vector3(0,-.225,-.005),Vector3(.26,.09,.27),seam)
		block(leg,Vector3(side*.085,-.17,-.109),Vector3(.115,.17,.03),green)
		oval(leg,Vector3(side*.085,-.11,-.13),Vector3(.035,.035,.015),gold)
		var ankle:=node(knee,Vector3(0,-.32,0),"Ankle")
		oval(ankle,Vector3(0,.035,-.027),Vector3(.23,.27,.29),leather)
		oval(ankle,Vector3(0,-.012,-.09),Vector3(.29,.20,.43),leather)
		oval(ankle,Vector3(0,-.087,-.082),Vector3(.31,.072,.45),sole)
		for j in range(4):
			for s in [-1,1]:
				block(ankle,Vector3(s*.132,-.107,-.23+j*.092),Vector3(.036,.037,.04),dark)
			line(ankle,Vector3(-.065,.116-j*.015,-.065-j*.030),Vector3(.065,.10-j*.015,-.094-j*.030),.007,gold)
		var arm:=node(root,Vector3(side*.32,1.20,0),"ArmL" if side<0 else "ArmR")
		oval(arm,Vector3(side*.018,-.095,0),Vector3(.245,.31,.25),yellow)
		var elbow:=node(arm,Vector3(side*.035,-.22,0),"Elbow")
		oval(elbow,Vector3(0,-.077,0),Vector3(.205,.245,.21),yellow)
		oval(elbow,Vector3(0,-.15,0),Vector3(.22,.065,.22),yellow)
		oval(elbow,Vector3(0,-.232,-.025),Vector3(.20,.205,.18),fur)
		oval(elbow,Vector3(-side*.082,-.208,-.06),Vector3(.095,.12,.10),fur)
		for finger in range(3):
			oval(elbow,Vector3(-.06+finger*.057,-.271,-.06),Vector3(.063,.081,.09),fur)
	# Chilean patch with geometric star.
	block(root,Vector3(-.105,1.225,-.224),Vector3(.115,.073,.012),white)
	block(root,Vector3(-.105,1.207,-.232),Vector3(.115,.036,.009),mat("db2430"))
	block(root,Vector3(-.14,1.243,-.233),Vector3(.045,.036,.009),mat("154fa6"))
	text3(root,Vector3(-.14,1.243,-.24),"★",.00048,Color.WHITE)
	# Beaver tail: flattened paddle behind the hips with a diamond pattern.
	var tail:=node(root,Vector3(.10,.53,.285),"Tail");tail.rotation.x=.30
	oval(tail,Vector3(0,-.06,.05),Vector3(.44,.65,.12),leather)
	for j in range(-3,4):
		var y:=float(j)*.067
		line(tail,Vector3(-.14,y-.13,.107),Vector3(.14,y+.07,.107),.004,dark)
		line(tail,Vector3(-.14,y+.07,.11),Vector3(.14,y-.13,.11),.004,dark)
	# Oversized friendly head, broad cheeks and layered eyes.
	var head:=node(root,Vector3(0,1.52,-.025),"Head")
	oval(head,Vector3.ZERO,Vector3(.76,.64,.60),fur)
	for side in [-1,1]:
		oval(head,Vector3(side*.355,.035,0),Vector3(.22,.24,.15),fur)
		oval(head,Vector3(side*.365,.035,-.07),Vector3(.13,.14,.045),inner)
		oval(head,Vector3(side*.245,-.11,-.145),Vector3(.28,.32,.31),fur)
		var eye:=node(head,Vector3(side*.155,.055,-.258),"EyeL" if side<0 else "EyeR")
		oval(eye,Vector3.ZERO,Vector3(.192,.225,.10),inner)
		oval(eye,Vector3(0,-.004,-.019),Vector3(.166,.199,.094),white)
		oval(eye,Vector3(-side*.009,-.012,-.066),Vector3(.103,.135,.036),iris)
		oval(eye,Vector3(-side*.009,-.01,-.084),Vector3(.063,.097,.018),dark)
		oval(eye,Vector3(-.024,.026,-.098),Vector3(.032,.038,.012),white)
		var brow:=oval(head,Vector3(side*.154,.205,-.26),Vector3(.19,.058,.05),dark);brow.rotation.z=side*.16
	oval(head,Vector3(0,-.189,-.253),Vector3(.29,.23,.105),mouth)
	oval(head,Vector3(0,-.263,-.313),Vector3(.145,.061,.023),tongue)
	for side in [-1,1]:
		oval(head,Vector3(side*.044,-.179,-.322),Vector3(.083,.113,.044),white)
		oval(head,Vector3(side*.093,-.085,-.305),Vector3(.23,.16,.15),muzzle)
		for j in range(3):
			oval(head,Vector3(side*(.12+j*.019),-.067-float(j%2)*.035,-.378+float(j)*.008),Vector3(.008,.008,.006),dark)
			line(head,Vector3(side*.17,-.087,-.363),Vector3(side*.40,-.015-j*.058,-.31),.002,white)
	oval(head,Vector3(0,-.043,-.392),Vector3(.162,.104,.096),dark)
	oval(head,Vector3(-.028,-.014,-.435),Vector3(.045,.021,.007),mat("865749",.3))
	# White safety helmet, brim, raised ribs and front wordmark.
	oval(head,Vector3(0,.272,.014),Vector3(.86,.43,.73),white)
	oval(head,Vector3(0,.144,-.045),Vector3(.91,.058,.82),white)
	for x in [-.24,0,.24]:
		oval(head,Vector3(x,.40,.016),Vector3(.055,.17,.48),white)
	text3(head,Vector3(0,.282,-.346),"Forestín",.0010,Color("005739"))
	var leaf:=oval(head,Vector3(.131,.35,-.333),Vector3(.025,.058,.012),mat("63ae3c"));leaf.rotation.z=-.35
	return root
