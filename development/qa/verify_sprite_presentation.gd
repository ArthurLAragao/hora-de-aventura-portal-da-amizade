extends "res://tests/journey_driver.gd"
## Precondição declarada: seis cristais disponíveis para inspecionar o epílogo isoladamente.
## O percurso completo da Fase 6 continua sendo validado pelo verify_journey_6.
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
const ART=preload("res://scripts/ui/sprite_art.gd")
func run() -> void:
	root.size=viewport_size
	await fresh("res://level_1.tscn",1,"finn_player_id")
	var hud=level.get_node("GameScreens").adventure_hud
	var story=level.get_node("FriendshipStory")
	check("conversa usa moldura PNG importada",story.card.get_theme_stylebox("panel") is StyleBoxTexture)
	check("relicário tem textura dedicada",hud.design.get_node("CrystalRelicary").texture.resource_path.ends_with("hud_crystals.png"))
	hud.set_process(false);hud.emblem.set_crystals([1,4]);await frames(100)
	check("somente cristais conquistados aparecem",hud.emblem.gems[0].visible and hud.emblem.gems[3].visible and not hud.emblem.gems[1].visible)
	check("brilho termina sem resíduos",hud.emblem.effects.all(func(n):return not n.visible))
	check("rotação tem oito frames reais",ART.frames().get_frame_count(&"spin")==8 and ART.frames().get_frame_texture(&"spin",0) is AtlasTexture)
	check("sprites usam filtro nearest",hud.emblem.gems.all(func(n):return n.texture_filter==CanvasItem.TEXTURE_FILTER_NEAREST))
	PROGRESS.collect(1);PROGRESS.collect(4);hud.sync();await capture("hud-sprites-settled")
	PROGRESS.write({"version":1,"completed":[1,2,3,4,5,6],"crystals":[1,2,3,4,5,6],"restored":false})
	await fresh("res://monument_finale.tscn",1,"primary_player_id")
	check("seis monumentos têm PNGs distintos",level.monument_sprites.size()==6 and level.monument_sprites[0].texture!=level.monument_sprites[1].texture)
	check("não há cristal instalado inicialmente",level.crystal_sprites.all(func(n):return not n.visible))
	await capture("monuments-empty")
	record_dir=capture_dir.path_join("ceremony-frames");record_interval=8;DirAccess.make_dir_recursive_absolute(record_dir)
	for i in 6:
		var target: float=level.pedestals[i].x
		check("parceira caminha até pedestal %d"%(i+1),await walk(level.actors[1],target-38))
		check("primeira caminha até pedestal %d"%(i+1),await walk(level.actors[0],target))
		await tap(level.actors[i%2],"interact");await frames(60)
		check("entrada instala só uma vez e efeito termina %d"%(i+1),level.placed.size()==i+1 and level.crystal_sprites[i].visible and not level.restoration_effects[i].visible)
		if i==2:await capture("monuments-half")
	await frames(350);record_dir=""
	check("celebração tem medalhão PNG e seis personagens originais",level.has_node("Celebration/CrystalEmblem/VictoryMedallion") and level.get_node("Celebration").friends.size()==6)
	check("cristais da vitória aparecem uma vez",level.get_node("Celebration").lit_count==6)
	await capture("victory-sprites")
	await finish("Sprites: recursos reais, estados de aquisição e epílogo por entradas")
