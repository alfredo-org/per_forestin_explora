extends RefCounted
## Procedural two-link legs. Physics owns position; pose follows actual displacement.
var model:Node3D
var state:="idle"
var blend:=0.0
var impact:=0.0
var phase:=0.0
var clock:=0.0
var joints:Array[Node3D]=[]
func _init(root:Node3D)->void:
	model=root
	for path in ["LegL","LegR","ArmL","ArmR","LegL/Knee","LegR/Knee","LegL/Knee/Ankle","LegR/Knee/Ankle","ArmL/Elbow","ArmR/Elbow"]:
		joints.append(model.get_node(path))
func reset()->void:
	state="idle";blend=0;impact=0;phase=0;clock=0
	model.position=Vector3.ZERO;model.rotation.x=0;model.rotation.z=0
	for joint in joints:joint.rotation=Vector3.ZERO
func update(delta:float,speed:float,grounded:bool,vertical_speed:float,landing:float)->void:
	clock+=delta
	impact=maxf(landing,impact*exp(-delta*13))
	blend=lerpf(blend,clampf(speed/3.2,0,1),1-exp(-delta*10))
	phase=fposmod(phase+speed*delta*TAU/(1.03 if speed>4.2 else .78),TAU)
	state="land" if impact>.12 else "rise" if not grounded and vertical_speed>0 else "fall" if not grounded else "run" if speed>4.2 else "walk" if blend>.08 else "idle"
	var crouch:=impact*.085
	model.position.y=-.025-crouch+(sin(clock*1.8)*.003 if blend<.1 else absf(sin(phase))*.012)
	model.rotation.x=lerpf(model.rotation.x,-.045*blend-.07*maxf(speed-3.2,0)/2.8,1-exp(-delta*8))
	model.rotation.z=sin(phase)*.015*blend
	for i in range(2):
		var t:=fposmod(phase/TAU+float(i)*.5,1.0)
		var swing:=maxf((t-.6)/.4,0)
		var reach:=.20 if speed<4.2 else .25
		var foot_z:=lerpf(-reach,reach,t/.6) if t<.6 else lerpf(reach,-reach,smoothstep(0,1,swing))
		var lift:=sin(swing*PI)*(.11 if speed<4.2 else .16)
		var drop:=.595-crouch-lift*blend
		if not grounded:drop=.49 if vertical_speed>0 else .55;foot_z=-.075 if i==0 else .075
		else:foot_z*=blend
		var distance:=clampf(Vector2(drop,foot_z).length(),.10,.639)
		var hip:=atan2(-foot_z,drop)+acos(clampf(distance/.64,-1,1))
		var knee:=-2*acos(clampf(distance/.64,-1,1))
		joints[i].rotation.x=lerpf(joints[i].rotation.x,hip,1-exp(-delta*24))
		joints[4+i].rotation.x=lerpf(joints[4+i].rotation.x,knee,1-exp(-delta*24))
		joints[6+i].rotation.x=-joints[i].rotation.x-joints[4+i].rotation.x
		var arm_swing:=-sin(phase+float(i)*PI)*.40*blend if grounded else -.45
		joints[2+i].rotation.x=lerpf(joints[2+i].rotation.x,arm_swing,1-exp(-delta*12))
		joints[8+i].rotation.x=lerpf(joints[8+i].rotation.x,-.18-.5*clampf((speed-3.2)/2.8,0,1),1-exp(-delta*10))
	var blink:=1.0-.92*maxf(0,1-absf(fposmod(clock,4.7)-4.4)/.10)
	model.get_node("Head/EyeL").scale.y=blink;model.get_node("Head/EyeR").scale.y=blink
