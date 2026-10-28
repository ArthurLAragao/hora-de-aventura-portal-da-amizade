extends "res://tests/verify_journey_6.gd"
## Full original input-driven route, plus rendered recordings. No route teleport/state setup.
var clips_root:=""
func _initialize() -> void:
	super._initialize()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--clips="):clips_root=arg.trim_prefix("--clips=")
func walk(actor: CoopPlayer,goal: float,limit: int=480) -> bool:
	var result:=await super.walk(actor,goal,limit)
	if actor.character_id==&"cake" and goal in [900.0,864.0] and actor.crawling:
		await super.capture("refine-tunnel-forward" if goal==900 else "refine-tunnel-retreat")
		check("tunnel cutaway preserves crawling and physical clearance",not actor.can_stand() and is_equal_approx(level.get_node("TunnelRoof").get_node("CollisionShape2D").shape.size.y,57.64714))
	return result
func capture(name: String) -> void:
	await super.capture(name)
	check(name+": three lights follow the real repair array",level.portal.light_states()==level.repaired and level.seals.all(func(s):return s.texture==null and not s.visible))
	if name=="phase6-signal":
		check("completed crank and tunnel switch no longer crowd the signal sector",not level.crank.visible and not level.get_node("SwitchIndicator").visible)
		check("walking surfaces retain original bounds",level.get_node("TunnelRoof").position==Vector2(912,level.FLOOR-51.17643) and level.get_node("Terrain").get_used_rect()==Rect2i(0,15,43,7))
		if role==1 and clips_root!="":await clip("portal-ativo",48)
func clip(folder: String,count: int) -> void:
	var out:=clips_root.path_join(folder)
	DirAccess.make_dir_recursive_absolute(out)
	for i in count:
		await frames(6)
		OS.delay_msec(70)
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("%03d.png"%i))
func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:await route(slot)
	await finish("Visual refinement normal route")
