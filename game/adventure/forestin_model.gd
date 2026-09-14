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
# Lofted contour surfaces: each garment/head is one indexed, smooth-normal mesh.
# Profile components: height, half-width, half-depth, depth offset.
static func contour(p:Node3D,pos:Vector3,profile:Array[Vector4],m:Material,fold:float=0.0)->MeshInstance3D:
	var rings:Array[Vector4]=[]
	for i in range(profile.size()-1):
		var a:Vector4=profile[maxi(i-1,0)];var b:Vector4=profile[i]
		var c:Vector4=profile[i+1];var d:Vector4=profile[mini(i+2,profile.size()-1)]
		for step in range(6):
			var t:=float(step)/6.0
			rings.append((2*b+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)*.5)
	rings.append(profile[-1])
	var vertices:=PackedVector3Array();var normals:=PackedVector3Array();var uv:=PackedVector2Array();var indices:=PackedInt32Array()
	var segments:=40
	for j in range(rings.size()):
		var r:Vector4=rings[j]
		var before:Vector4=rings[maxi(j-1,0)];var after:Vector4=rings[mini(j+1,rings.size()-1)]
		for k in range(segments+1):
			var angle:=TAU*float(k)/segments
			var crease:=1.0+fold*sin(angle*5.0+r.x*33.0)*sin(PI*float(j)/float(rings.size()-1))
			var rx:=maxf(.001,r.y);var rz:=maxf(.001,r.z)
			vertices.append(Vector3(rx*cos(angle)*crease,r.x,r.w+rz*sin(angle)*crease))
			var up:=Vector3((after.y-before.y)*cos(angle),after.x-before.x,after.w-before.w+(after.z-before.z)*sin(angle))
			var tangent:=Vector3(-rx*sin(angle),0,rz*cos(angle))
			normals.append(up.cross(tangent).normalized())
			uv.append(Vector2(float(k)/segments,float(j)/float(rings.size()-1)))
	for j in range(rings.size()-1):
		for k in range(segments):
			var a:=j*(segments+1)+k;var b:=a+segments+1
			for index in [a,a+1,b,a+1,b+1,b]:indices.append(index)
	var arrays:=[];arrays.resize(Mesh.ARRAY_MAX);arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_NORMAL]=normals;arrays[Mesh.ARRAY_TEX_UV]=uv;arrays[Mesh.ARRAY_INDEX]=indices
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=m;n.position=pos;p.add_child(n);return n
# Curved bib and straps follow the chest instead of sitting on a flat plate.
static func chest_front(x:float,y:float)->float:
	var width:=.324;var depth:=.307;var center:=.018
	if y>1.02:
		var t:=clampf((y-1.02)/.27,0,1)
		width=lerpf(.324,.27,t);depth=lerpf(.307,.225,t);center=lerpf(.018,.035,t)
	return center-depth*sqrt(maxf(.01,1.0-pow(x/width,2)))-.013
static func cloth_panel(p:Node3D,m:Material,left:float,right:float,bottom:float,top:float,taper:float)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols:=16;var rows:=16
	var points:Array[Vector3]=[]
	for j in range(rows+1):
		var v:=float(j)/rows;var y:=lerpf(bottom,top,v)
		for i in range(cols+1):
			var x:=lerpf(left,right,float(i)/cols)*lerpf(1.0,taper,v)
			points.append(Vector3(x,y,chest_front(x,y)))
	for j in range(rows):
		for i in range(cols):
			var a:=j*(cols+1)+i;var b:=a+cols+1
			for k in [a,b,a+1,a+1,b,b+1]:
				st.set_smooth_group(0);st.add_vertex(points[k])
	st.generate_normals()
	var n:=MeshInstance3D.new();n.mesh=st.commit();n.material_override=m;p.add_child(n)
static func bib(p:Node3D,m:Material)->void:
	cloth_panel(p,m,-.26,.26,.86,1.145,.83)
static func strap(p:Node3D,side:float,m:Material)->void:
	var center:=side*.211
	cloth_panel(p,m,center-.04,center+.04,1.10,1.305,.91)
	# Matching shoulder straps on the back make the outfit readable from behind.
	var back:=contour(p,Vector3(center,0,.228),[Vector4(.94,.035,.023,0),Vector4(1.10,.037,.028,.03),Vector4(1.23,.036,.023,-.012),Vector4(1.30,.031,.017,-.074)],m)
	back.name="BackStrapL" if side<0 else "BackStrapR"
static func build()->Node3D:
	var root:=Node3D.new();root.name="Forestin"
	var fur:=mat("e98122");var inner:=mat("bc5017");var muzzle:=mat("ffe0a0")
	var green:=mat("006344");var seam:=mat("004631");var yellow:=mat("ffca19")
	var white:=mat("fff9ed",.35);var gold:=mat("edb650",.3);var leather:=mat("a94d21",.5);var sole:=mat("d68035")
	var dark:=mat("29140c",.35);var mouth:=mat("40110f");var tongue:=mat("e85459");var iris:=mat("934211",.25)
	# Rounded work shirt and overalls. Front of the character is -Z.
	contour(root,Vector3.ZERO,[Vector4(.76,.22,.205,.025),Vector4(.86,.315,.285,.018),Vector4(1.02,.324,.307,.018),Vector4(1.19,.318,.285,.028),Vector4(1.29,.27,.225,.035),Vector4(1.37,.13,.142,.022),Vector4(1.39,.001,.001,0)],yellow,.009)
	contour(root,Vector3.ZERO,[Vector4(.64,.16,.16,.022),Vector4(.71,.29,.255,.03),Vector4(.84,.325,.295,.02),Vector4(.93,.321,.304,.016),Vector4(.955,.316,.301,.014)],green,.012)
	bib(root,green)
	block(root,Vector3(0,.94,-.305),Vector3(.29,.20,.025),seam)
	oval(root,Vector3(0,.94,-.326),Vector3(.28,.21,.035),green)
	text3(root,Vector3(0,.95,-.347),"CONAF",.00062,Color.WHITE)
	for side in [-1,1]:
		strap(root,float(side),green)
		block(root,Vector3(side*.215,1.195,-.203),Vector3(.092,.061,.022),gold)
		block(root,Vector3(side*.215,1.195,-.218),Vector3(.065,.032,.008),green)
		oval(root,Vector3(side*.205,1.08,-.235),Vector3(.051,.051,.022),gold)
		var collar:=block(root,Vector3(side*.085,1.31,-.209),Vector3(.13,.095,.05),yellow);collar.rotation.z=side*.40
		var leg:=node(root,Vector3(side*.18,.74,.01),"LegL" if side<0 else "LegR")
		contour(leg,Vector3.ZERO,[Vector4(-.36,.118,.145,0),Vector4(-.30,.13,.156,0),Vector4(-.18,.151,.184,.008),Vector4(-.03,.162,.199,.014),Vector4(.055,.128,.155,.014)],green,.017)
		var knee:=node(leg,Vector3(0,-.32,0),"Knee")
		contour(knee,Vector3.ZERO,[Vector4(-.27,.126,.14,0),Vector4(-.235,.131,.152,0),Vector4(-.19,.13,.155,.012),Vector4(-.08,.137,.164,.012),Vector4(.025,.126,.154,0)],green,.023)
		oval(knee,Vector3(0,-.225,-.005),Vector3(.28,.09,.31),seam)
		block(leg,Vector3(side*.085,-.17,-.157),Vector3(.115,.17,.03),green)
		oval(leg,Vector3(side*.085,-.11,-.183),Vector3(.035,.035,.015),gold)
		var ankle:=node(knee,Vector3(0,-.32,0),"Ankle")
		oval(ankle,Vector3(0,.035,-.027),Vector3(.23,.27,.29),leather)
		oval(ankle,Vector3(0,-.012,-.09),Vector3(.29,.20,.43),leather)
		oval(ankle,Vector3(0,-.087,-.082),Vector3(.31,.072,.45),sole)
		for j in range(4):
			for s in [-1,1]:
				block(ankle,Vector3(s*.132,-.107,-.23+j*.092),Vector3(.036,.037,.04),dark)
			line(ankle,Vector3(-.065,.116-j*.015,-.065-j*.030),Vector3(.065,.10-j*.015,-.094-j*.030),.007,gold)
		var arm:=node(root,Vector3(side*.367,1.20,.02),"ArmL" if side<0 else "ArmR")
		contour(arm,Vector3(side*.018,0,0),[Vector4(-.25,.098,.121,0),Vector4(-.16,.123,.142,0),Vector4(-.035,.145,.163,.01),Vector4(.055,.113,.135,.01),Vector4(.092,.001,.001,0)],yellow,.016)
		var elbow:=node(arm,Vector3(side*.035,-.22,0),"Elbow")
		contour(elbow,Vector3.ZERO,[Vector4(-.174,.099,.112,0),Vector4(-.135,.109,.124,0),Vector4(-.065,.12,.135,.008),Vector4(.034,.102,.121,0)],yellow,.023)
		oval(elbow,Vector3(0,-.15,0),Vector3(.24,.065,.255),yellow)
		oval(elbow,Vector3(0,-.232,-.025),Vector3(.222,.215,.215),fur)
		oval(elbow,Vector3(-side*.082,-.208,-.06),Vector3(.095,.12,.10),fur)
		for finger in range(3):
			oval(elbow,Vector3(-.06+finger*.057,-.271,-.06),Vector3(.063,.081,.09),fur)
	# Chilean patch with geometric star.
	block(root,Vector3(-.105,1.225,-.227),Vector3(.115,.073,.012),white)
	block(root,Vector3(-.105,1.207,-.245),Vector3(.115,.036,.009),mat("db2430"))
	block(root,Vector3(-.14,1.243,-.223),Vector3(.045,.036,.009),mat("154fa6"))
	text3(root,Vector3(-.14,1.243,-.232),"★",.00048,Color.WHITE)
	# Oversized friendly head, broad cheeks and layered eyes.
	var head:=node(root,Vector3(0,1.52,-.025),"Head")
	contour(head,Vector3.ZERO,[Vector4(-.322,.001,.001,-.025),Vector4(-.295,.15,.115,-.04),Vector4(-.23,.29,.215,-.018),Vector4(-.13,.365,.284,-.012),Vector4(-.02,.368,.295,0),Vector4(.12,.329,.274,.015),Vector4(.23,.26,.22,.024),Vector4(.30,.12,.12,.02),Vector4(.32,.001,.001,.02)],fur)
	for side in [-1,1]:
		oval(head,Vector3(side*.355,.035,0),Vector3(.22,.24,.15),fur)
		oval(head,Vector3(side*.365,.035,-.07),Vector3(.13,.14,.045),inner)
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
	contour(head,Vector3.ZERO,[Vector4(.145,.422,.35,.01),Vector4(.20,.416,.345,.014),Vector4(.30,.373,.314,.02),Vector4(.395,.295,.255,.03),Vector4(.456,.16,.145,.035),Vector4(.475,.001,.001,.035)],white)
	oval(head,Vector3(0,.144,-.045),Vector3(.91,.058,.82),white)
	for x in [-.24,0,.24]:
		oval(head,Vector3(x,.40,.016),Vector3(.055,.17,.48),white)
	text3(head,Vector3(0,.282,-.335),"Forestín",.0010,Color("005739"))
	var leaf:=oval(head,Vector3(.131,.35,-.29),Vector3(.025,.058,.012),mat("63ae3c"));leaf.rotation.z=-.35
	return root
