extends RefCounted
## Forestin reference costume and face, constructed entirely from native 3D geometry.
static func mat(hex:String,rough:float=.7)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=Color(hex);m.roughness=rough;m.metallic_specular=.32;return m
static func fabric(hex:String)->ShaderMaterial:
	var m:=ShaderMaterial.new();m.shader=preload("res://adventure/cloth.gdshader")
	m.set_shader_parameter("fabric_color",Color(hex));return m
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
# Bake narrow molded details into one mesh per path, avoiding per-segment draw calls.
static func rib_path(p:Node3D,points:PackedVector3Array,radius:float,m:Material)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size()-1):
		var a:=points[i];var b:=points[i+1]
		if a.distance_squared_to(b)<.00000001:continue
		var cylinder:=CylinderMesh.new();cylinder.top_radius=radius;cylinder.bottom_radius=radius;cylinder.height=a.distance_to(b);cylinder.radial_segments=8
		var basis:=Basis(Quaternion(Vector3.UP,(b-a).normalized()))
		st.append_from(cylinder,0,Transform3D(basis,(a+b)*.5))
	var n:=MeshInstance3D.new();n.mesh=st.commit();n.material_override=m;p.add_child(n)
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
	# Close each loft at both ends. Duplicate rim normals for a clean fabric edge.
	for end in [0,rings.size()-1]:
		var r:Vector4=rings[end]
		var normal:=Vector3.DOWN if end==0 else Vector3.UP
		var center:=vertices.size()
		vertices.append(Vector3(0,r.x,r.w));normals.append(normal);uv.append(Vector2(.5,.5))
		for k in range(segments+1):
			vertices.append(vertices[end*(segments+1)+k]);normals.append(normal);uv.append(Vector2.ZERO)
		for k in range(segments):
			indices.append(center)
			indices.append(center+2+k if end==0 else center+1+k)
			indices.append(center+1+k if end==0 else center+2+k)
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
static func cloth_panel(p:Node3D,m:Material,left:float,right:float,bottom:float,top:float,taper:float,offset:float=0.0,rounded:bool=false)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var cols:=16;var rows:=16
	var points:Array[Vector3]=[]
	for j in range(rows+1):
		var v:=float(j)/rows;var y:=lerpf(bottom,top,v)
		for i in range(cols+1):
			var edge:=1.0
			if rounded:
				# Pocket corners curve into the garment instead of forming a box.
				var corner:=clampf((absf(v-.5)-.34)/.16,0.0,1.0)
				edge=1.0-.17*(1.0-sqrt(maxf(0.0,1.0-corner*corner)))
			var x:=(lerpf(left,right,float(i)/cols)-(left+right)*.5)*edge*lerpf(1.0,taper,v)+(left+right)*.5
			points.append(Vector3(x,y,chest_front(x,y)-offset))
	for j in range(rows):
		for i in range(cols):
			var a:=j*(cols+1)+i;var b:=a+cols+1
			for k in [a,a+1,b,a+1,b+1,b]:
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
	var green:=fabric("006344");var seam:=fabric("004631");var yellow:=fabric("efb622")
	var white:=mat("fff9ed",.47);var gold:=mat("edb650",.38);var leather:=mat("a94d21",.68);var sole:=mat("b96f34",.86)
	var dark:=mat("29140c",.35);var iris:=mat("934211",.25)
	# Rounded work shirt and overalls. Front of the character is -Z.
	contour(root,Vector3.ZERO,[Vector4(.76,.22,.205,.025),Vector4(.86,.315,.285,.018),Vector4(1.02,.324,.307,.018),Vector4(1.19,.318,.285,.028),Vector4(1.29,.27,.225,.035),Vector4(1.37,.13,.142,.022),Vector4(1.39,.001,.001,0)],yellow,.009)
	contour(root,Vector3.ZERO,[Vector4(.64,.16,.16,.022),Vector4(.71,.29,.255,.03),Vector4(.84,.325,.295,.02),Vector4(.93,.321,.304,.016),Vector4(.955,.316,.301,.014)],green,.012)
	bib(root,green)
	cloth_panel(root,seam,-.151,.151,.858,1.052,1.0,.003,true)
	cloth_panel(root,green,-.144,.144,.865,1.046,1.0,.005,true)
	text3(root,Vector3(0,.95,-.329),"CONAF",.00062,Color.WHITE)
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
		# One flowing leather upper: broad toe, arched instep, narrower ankle.
		contour(ankle,Vector3.ZERO,[Vector4(-.068,.137,.197,-.080),Vector4(-.042,.144,.204,-.083),Vector4(.004,.139,.194,-.083),Vector4(.046,.123,.158,-.068),Vector4(.098,.111,.132,-.033),Vector4(.160,.107,.119,-.013)],leather)
		# Shaped outsole and a thin welt follow the same footprint.
		contour(ankle,Vector3.ZERO,[Vector4(-.116,.136,.203,-.080),Vector4(-.106,.151,.219,-.080),Vector4(-.077,.153,.221,-.080),Vector4(-.065,.144,.210,-.080)],sole)
		contour(ankle,Vector3.ZERO,[Vector4(-.072,.145,.211,-.080),Vector4(-.061,.146,.211,-.080),Vector4(-.056,.140,.204,-.080)],leather)
		for j in range(4):
			for s in [-1,1]:
				block(ankle,Vector3(s*.132,-.107,-.23+j*.092),Vector3(.036,.037,.04),dark)
			line(ankle,Vector3(-.065,.116-j*.015,-.065-j*.030),Vector3(.065,.10-j*.015,-.094-j*.030),.007,gold)
		var arm:=node(root,Vector3(side*.335,1.22,.02),"ArmL" if side<0 else "ArmR")
		var elbow:=node(arm,Vector3(side*.035,-.22,0),"Elbow")
		contour(elbow,Vector3.ZERO,[Vector4(-.185,.097,.112,0),Vector4(-.176,.111,.123,0),Vector4(-.151,.112,.124,0),Vector4(-.143,.105,.118,0)],yellow)
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
	# Closed lips with a curved seam; expression scales the curve, never opens a cavity.
	var lips:=node(head,Vector3(0,-.18,-.317),"Mouth")
	for j in range(16):
		var x0:=lerpf(-.115,.115,float(j)/16)
		var x1:=lerpf(-.115,.115,float(j+1)/16)
		line(lips,Vector3(x0,.010*pow(x0/.115,2),.042*pow(x0/.115,2)),Vector3(x1,.010*pow(x1/.115,2),.042*pow(x1/.115,2)),.0035,dark)
	for side in [-1,1]:
		oval(head,Vector3(side*.093,-.085,-.305),Vector3(.23,.16,.15),muzzle)
		for j in range(3):
			oval(head,Vector3(side*(.12+j*.019),-.067-float(j%2)*.035,-.378+float(j)*.008),Vector3(.008,.008,.006),dark)
			line(head,Vector3(side*.17,-.087,-.363),Vector3(side*.40,-.015-j*.058,-.31),.002,white)
	oval(head,Vector3(0,-.043,-.392),Vector3(.162,.104,.096),dark)
	oval(head,Vector3(-.028,-.014,-.435),Vector3(.045,.021,.007),mat("865749",.3))
	# White safety helmet: continuous shell, thin shaped brim and low molded ribs.
	var helmet_profile:Array[Vector4]=[Vector4(.145,.422,.35,.01),Vector4(.20,.416,.345,.014),Vector4(.30,.373,.314,.02),Vector4(.395,.295,.255,.03),Vector4(.456,.16,.145,.035),Vector4(.475,.001,.001,.035)]
	contour(head,Vector3.ZERO,helmet_profile,white)
	contour(head,Vector3.ZERO,[Vector4(.123,.410,.356,-.020),Vector4(.133,.448,.395,-.025),Vector4(.149,.450,.397,-.025),Vector4(.160,.422,.352,.01)],white)
	# Sample the same shell loft for shallow molded ribs with no floating pieces.
	for side in [-1,0,1]:
		for front in [-1,1]:
			var points:=PackedVector3Array()
			for i in range(helmet_profile.size()-1):
				var a:Vector4=helmet_profile[maxi(i-1,0)];var b:Vector4=helmet_profile[i]
				var c:Vector4=helmet_profile[i+1];var d:Vector4=helmet_profile[mini(i+2,helmet_profile.size()-1)]
				for j in range(6):
					var t:=float(j)/6.0
					var r:Vector4=(2*b+(-a+c)*t+(2*a-5*b+4*c-d)*t*t+(-a+3*b-3*c+d)*t*t*t)*.5
					var fraction:=float(side)*.44
					var point:=Vector3(r.y*fraction,r.x,r.w+float(front)*r.z*sqrt(1.0-fraction*fraction))
					points.append(point)
			rib_path(head,points,.005,white)
	text3(head,Vector3(0,.282,-.335),"Forestín",.0010,Color("005739"))
	var leaf:=oval(head,Vector3(.131,.35,-.29),Vector3(.025,.058,.012),mat("63ae3c"));leaf.rotation.z=-.35
	var rig:=preload("res://adventure/garment_rig.gd").new();rig.name="GarmentRig";root.add_child(rig);rig.configure(root)
	for side in [-1,1]:
		var arm:Node3D=root.get_node("ArmL" if side<0 else "ArmR")
		# A single surface flows from the shoulder into the wrist; folds are part of the mesh.
		var sleeve:=contour(root,Vector3.ZERO,[Vector4(-.395,.096,.110,0),Vector4(-.35,.106,.122,.002),Vector4(-.27,.112,.129,.005),Vector4(-.20,.116,.135,.008),Vector4(-.11,.133,.150,.009),Vector4(-.015,.139,.158,.008),Vector4(.065,.101,.124,.006),Vector4(.112,.026,.040,.004),Vector4(.12,.001,.001,.004)],yellow,.014)
		sleeve.name="SleeveL" if side<0 else "SleeveR"
		var arrays:=sleeve.mesh.surface_get_arrays(0)
		var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		var bones:=PackedInt32Array();var weights:=PackedFloat32Array()
		var upper:=1 if side<0 else 3
		for i in range(vertices.size()):
			var p:=vertices[i]
			var lower_weight:=1.0-smoothstep(-.30,-.15,p.y)
			var torso_weight:=smoothstep(.015,.105,p.y)
			# Offset follows the forearm rest center and tucks the shoulder into the shirt.
			p.x+=float(side)*lerpf(.012,.035,lower_weight)-float(side)*.065*torso_weight
			vertices[i]=arm.transform*p
			bones.append_array(PackedInt32Array([0,upper,upper+1,0]))
			weights.append_array(PackedFloat32Array([torso_weight,(1.0-torso_weight)*(1.0-lower_weight),(1.0-torso_weight)*lower_weight,0.0]))
		arrays[Mesh.ARRAY_VERTEX]=vertices;arrays[Mesh.ARRAY_BONES]=bones;arrays[Mesh.ARRAY_WEIGHTS]=weights
		var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		sleeve.mesh=mesh;sleeve.skin=rig.garment_skin;sleeve.skeleton=NodePath("../GarmentRig")
		# Includes the complete walk/run/jump envelope, avoiding rest-pose culling.
		sleeve.custom_aabb=AABB(Vector3(-.8,.4,-.65),Vector3(1.6,1.25,1.3))
	return root
