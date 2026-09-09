extends RefCounted
const FILE:="user://forestin_pathfinder_v1.json"
static func fresh()->Dictionary:return {"version":1,"stage":0,"collected":[],"night":false}
static func sanitize(raw:Variant)->Dictionary:
	var result:=fresh()
	if not raw is Dictionary or raw.get("version")!=1:return result
	var stage:Variant=raw.get("stage",0)
	if stage is float or stage is int:
		if is_finite(float(stage)):result.stage=clampi(int(stage),0,4)
	var items:Variant=raw.get("collected",[])
	if items is Array:
		for i in items:
			if (i is int or i is float) and is_finite(float(i)) and i>=0 and i<3 and i==floor(i) and not result.collected.has(int(i)):result.collected.append(int(i))
	if result.stage>=3 and result.collected.size()<3:result.stage=2
	result.night=raw.get("night",false)==true
	return result
static func read(path:String=FILE)->Dictionary:
	if not FileAccess.file_exists(path):return fresh()
	var f:=FileAccess.open(path,FileAccess.READ)
	if f==null or f.get_length()>16384:return fresh()
	var parser:=JSON.new()
	if parser.parse(f.get_as_text())!=OK:return fresh()
	return sanitize(parser.data)
static func save(data:Dictionary,path:String=FILE)->bool:
	var f:=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if f==null:return false
	f.store_string(JSON.stringify(sanitize(data)));f.flush();f.close()
	return DirAccess.rename_absolute(path+".tmp",path)==OK
