extends CharacterBody3D
const Shapes = preload("res://adventure/shapes.gd")
var active := false
var yaw := 0.0
var pitch := -0.23
var visual: Node3D
var pivot: Node3D
var arm: SpringArm3D
var camera: Camera3D
var gait := 0.0
var coyote := 0.0
var jump_buffer := 0.0
func _ready() -> void:
	collision_layer=2
	collision_mask=1|4
	floor_snap_length=0.35
	floor_max_angle=deg_to_rad(48)
	var collider:=CollisionShape3D.new()
	var capsule:=CapsuleShape3D.new()
	capsule.radius=0.28;capsule.height=1.8
	collider.shape=capsule;collider.position.y=0.90
	add_child(collider)
	visual=Shapes.forestin();add_child(visual)
	pivot=Node3D.new();add_child(pivot);pivot.position.y=1.42
	arm=SpringArm3D.new();arm.spring_length=5.0;arm.margin=0.23;arm.collision_mask=1
	var probe:=SphereShape3D.new();probe.radius=0.17;arm.shape=probe
	pivot.add_child(arm)
	camera=Camera3D.new();camera.current=true;camera.fov=62;camera.near=0.08;camera.far=500
	arm.add_child(camera)
func set_active(value:bool)->void:
	active=value
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED if value else Input.MOUSE_MODE_VISIBLE
	if not value:velocity.x=0;velocity.z=0
func reset_to(pos:Vector3)->void:
	global_position=pos;velocity=Vector3.ZERO;coyote=0;jump_buffer=0
func _unhandled_input(event:InputEvent)->void:
	if active and event is InputEventMouseMotion:
		yaw-=event.relative.x*0.0027
		pitch=clampf(pitch-event.relative.y*0.0027,-1.10,0.30)
func _physics_process(delta:float)->void:
	var movement:=Vector2.ZERO
	if active:
		movement=Input.get_vector("move_left","move_right","move_forward","move_backward")
		yaw-=Input.get_axis("look_left","look_right")*delta*2
		pitch=clampf(pitch-Input.get_axis("look_up","look_down")*delta*1.5,-1.10,0.30)
		if Input.is_action_just_pressed("jump"):jump_buffer=0.13
	pivot.rotation=Vector3(pitch,yaw,0)
	coyote=0.12 if is_on_floor() else maxf(0,coyote-delta)
	jump_buffer=maxf(0,jump_buffer-delta)
	var speed:=6.0 if active and Input.is_action_pressed("sprint") else 3.2
	var direction:=Basis(Vector3.UP,yaw)*Vector3(movement.x,0,movement.y)
	velocity.x=move_toward(velocity.x,direction.x*speed,delta*14)
	velocity.z=move_toward(velocity.z,direction.z*speed,delta*14)
	if not is_on_floor():velocity.y-=19.6*delta
	if active and coyote>0 and jump_buffer>0:
		velocity.y=6.6;coyote=0;jump_buffer=0
	move_and_slide()
	var planar:=Vector2(velocity.x,velocity.z).length()
	if planar>0.12:visual.rotation.y=lerp_angle(visual.rotation.y,atan2(-velocity.x,-velocity.z),1-exp(-delta*12))
	gait+=planar*delta*3.6
	var amount:=minf(planar/3.2,1.25) if is_on_floor() else 0.12
	for name in ["LegL","ArmR"]:visual.get_node(name).rotation.x=sin(gait)*0.45*amount
	for name in ["LegR","ArmL"]:visual.get_node(name).rotation.x=-sin(gait)*0.45*amount
	visual.position.y=absf(sin(gait))*0.028*amount
