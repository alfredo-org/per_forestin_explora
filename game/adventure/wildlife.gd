extends CharacterBody3D
const Shapes=preload("res://adventure/shapes.gd")
var player:Node3D
var home:=Vector3.ZERO
var state:="grazing"
var active:=true
var visual:Node3D
var gait:=0.0
var phase:=0.0
func _ready()->void:
	collision_layer=4;collision_mask=1|2|4;floor_snap_length=0.4
	var collider:=CollisionShape3D.new();var capsule:=CapsuleShape3D.new()
	capsule.radius=0.31;capsule.height=1.5;collider.shape=capsule;collider.position.y=0.78;add_child(collider)
	visual=Shapes.guanaco();add_child(visual)
	phase=home.x*0.7
func _physics_process(delta:float)->void:
	phase+=delta
	var direction:=Vector3.ZERO
	if active and is_instance_valid(player):
		var distance:=global_position.distance_to(player.global_position)
		state="retreat" if distance<6 or (state=="retreat" and distance<9) else "watch" if distance<11 or (state=="watch" and distance<13) else "return" if global_position.distance_to(home)>0.7 else "grazing"
		if state=="retreat":direction=(global_position-player.global_position);direction.y=0;direction=direction.normalized()*2.7
		elif state=="return":direction=home-global_position;direction.y=0;direction=direction.normalized()*0.8
		var future:=global_position+direction*delta
		if Vector2(future.x-home.x,future.z-home.z).length()>9.0:direction=Vector3.ZERO;state="watch"
		if direction.length()>0.1:
			var ray:=PhysicsRayQueryParameters3D.create(global_position+Vector3.UP*0.6,global_position+Vector3.UP*0.6+direction.normalized()*0.9,1)
			if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():direction=Vector3.ZERO
	velocity.x=move_toward(velocity.x,direction.x,delta*5)
	velocity.z=move_toward(velocity.z,direction.z,delta*5)
	if not is_on_floor():velocity.y-=19.6*delta
	move_and_slide()
	var speed:=Vector2(velocity.x,velocity.z).length()
	if speed>0.08:visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-velocity.x,-velocity.z),1-exp(-delta*5))
	gait+=speed*delta*5
	for i in range(4):visual.get_node("Leg%d"%i).rotation.x=sin(gait+(0 if i==0 or i==3 else PI))*minf(speed,1.0)*0.4
	visual.get_node("Neck").rotation.x=lerpf(visual.get_node("Neck").rotation.x,(-1.05+sin(phase)*0.04) if state=="grazing" else 0.0,1-exp(-delta*2))
