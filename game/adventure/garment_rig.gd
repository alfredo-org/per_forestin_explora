extends Skeleton3D
## Independent model-space bones follow the existing gameplay animation drivers.
## Sleeve vertices blend torso / upper arm / forearm, eliminating the rigid elbow seam.
var drivers:Array[Node3D]=[]
var garment_skin:=Skin.new()
func configure(model:Node3D)->void:
	for path in [".","ArmL","ArmL/Elbow","ArmR","ArmR/Elbow"]:
		var driver:Node3D=model.get_node(path)
		drivers.append(driver)
		var index:=get_bone_count()
		add_bone("GarmentBone"+str(index))
		var rest:=driver_transform(index)
		set_bone_rest(index,rest)
		garment_skin.add_bind(index,rest.affine_inverse())
	sync_pose()
func driver_transform(index:int)->Transform3D:
	if index==0:return Transform3D.IDENTITY
	if index==2 or index==4:return drivers[index-1].transform*drivers[index].transform
	return drivers[index].transform
func sync_pose()->void:
	for i in range(drivers.size()):
		var pose:=driver_transform(i)
		set_bone_pose_position(i,pose.origin)
		set_bone_pose_rotation(i,pose.basis.get_rotation_quaternion())
		set_bone_pose_scale(i,pose.basis.get_scale())
