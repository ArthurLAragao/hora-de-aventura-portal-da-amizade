extends SceneTree
## Resource and mathematical checks, separate from actual traversal evidence.
var failures:=0
var results: Array=[]
var report:=""
func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="):report=arg.trim_prefix("--report=")
	call_deferred("run")
func check(label: String,ok: bool) -> void:
	results.append({"check":label,"passed":ok})
	if not ok:failures+=1
func run() -> void:
	check("game does not contain the old tests directory",not DirAccess.dir_exists_absolute("res://tests"))
	for name in ["cake_tunnel","fionna_crank","music_panel","symbol_terminal"]:
		var node=load("res://mechanisms/"+name+".tscn").instantiate()
		check("standalone mechanism does not instantiate a test room: "+name,node.find_children("*","CharacterBody2D",true,false).is_empty())
		node.free()
	var portal=Node2D.new();portal.set_script(load("res://scripts/scenery/portal_sanctuary.gd"))
	var cells: Array[Vector2]=[];var identical:=true
	for y in range(-61,-6):
		for x in range(-20,21):
			var cell:=Vector2(x,y)
			if [cell,cell+Vector2.RIGHT,cell+Vector2.DOWN,cell+Vector2.ONE].all(func(p):return Geometry2D.is_point_in_polygon(p,portal.OPENING)):cells.append(cell)
	check("portal cache contains exactly the original aperture cells",cells==portal._aperture_cells)
	for i in cells.size():
		var cell:=cells[i];var v:=Vector2(cell.x,(cell.y+32)*0.65)
		for time in [0.0,0.33,1.25,3.0,5.71]:
			var old:=sin(v.length()*0.65-atan2(v.y,v.x)*2.0-time*1.1)
			var now:=sin(portal._wave_phase[i]-time*1.1)
			if absf(old-now)>0.000001:identical=false
	check("cached portal coefficients preserve the original wave",identical)
	portal.free()
	if report!="":FileAccess.open(report,FileAccess.WRITE).store_string(JSON.stringify({"checks":results,"failures":failures},"\t"))
	print("Optimization checks: ",results.size()," failures: ",failures)
	quit(0 if failures==0 else 1)
