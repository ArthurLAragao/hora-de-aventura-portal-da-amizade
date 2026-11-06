extends "res://tests/journey_driver.gd"
## Estados preparados validam HUD e transições; não representam solução dos puzzles.
const KEYS={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}

func shot(name: String) -> void:
	DisplayServer.window_move_to_foreground();await frames(3);RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(capture_dir.path_join(name+".png"))

func run() -> void:
	root.size=Vector2i(1280,720)
	remove_meta("friendship_crystals") if has_meta("friendship_crystals") else null
	for slot in [1,2]:
		for phase in range(1,7):
			await fresh("res://level_%d.tscn"%phase,slot,KEYS[phase]);await frames(30)
			var screens=level.get_node("GameScreens");var hud=screens.adventure_hud
			check("F%d HUD visível e sem cristais inventados"%phase,hud.visible and hud.acquired.is_empty())
			for actor in get_nodes_in_group("players"):
				check("F%d retrato acompanha %s em P%d"%[phase,actor.character_id,actor.player_id],hud.roles[actor.player_id-1].text.to_lower()==String(actor.character_id))
			for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
				root.size=size;await frames(5)
				check("F%d HUD enquadrada %s"%[phase,size],Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(hud.design.get_global_rect()))
				var story=level.get_node("FriendshipStory")
				var hud_bottom: float=hud.design.position.y+118.0*hud.design.scale.y
				check("F%d diálogo abaixo da HUD sem sobreposição %s"%[phase,size],story.card.position.y>hud_bottom)
			if slot==1:await shot("hud-f%d"%phase)
			if phase==6:
				level._repair(0);level._advance_pair(1);await until(func():return not level._transitioning,180);await frames(20)
				check("HUD atualiza Fionna e Cake sem manter retratos antigos",hud.roles.any(func(label):return label.text=="Fionna") and hud.roles.any(func(label):return label.text=="Cake"))
				await shot("hud-troca-dupla")
	root.size=Vector2i(1280,720)
	for phase in range(1,6):
		await fresh("res://level_%d.tscn"%phase,2,KEYS[phase]);await frames(24)
		var screens=level.get_node("GameScreens")
		# Exercita a coleta persistente, inclusive depois de o sprite sumir.
		match phase:
			1:level.crystal_count=1
			2:level.crystal_collected=true
			3,4:level.get_node("CooperativeExit")._crystal_collected=true
			5:level.exit_area._crystal_collected=true
		await frames(20);screens.adventure_hud.sync()
		check("coleta F%d atualiza emblema uma vez"%phase,screens.adventure_hud.acquired.size()==phase and phase in screens.adventure_hud.acquired)
		# Usa o encerramento verdadeiro: algumas fases desativam os corpos ao concluir.
		match phase:
			1:level._complete()
			2:level._complete_level()
			3,4:level._on_imported_completion()
			5:level.complete()
		await frames(20)
		screens.continue_phase();await frames(12)
		check("vinheta F%d abre e pausa só a fase encerrada"%phase,paused and screens.interlude!=null and screens.leaving)
		var travel=screens.interlude
		var positions: Array=get_nodes_in_group("players").map(func(a):return a.position)
		await frames(70)
		check("dupla parada enquanto vinheta anima",get_nodes_in_group("players")[0].position==positions[0])
		check("sprites originais caminham na vinheta",travel.actors.size()==2 and travel.actors[0].is_playing())
		await shot("viagem-%d"%phase)
		if phase!=2:travel.finish();travel.finish()
		# Fase 2 testa o encerramento automático, demais testam pular de modo idempotente.
		var reached:=await until(func():return is_instance_valid(current_scene) and current_scene!=level,600)
		level=current_scene;await frames(24)
		check("vinheta chega à próxima fase sem pausa residual",reached and not paused and level.scene_file_path=="res://level_%d.tscn"%(phase+1))
		check("coleção viaja sem conceder próximo cristal",get_meta("friendship_crystals").size()==phase)
		var expected:=1 if phase in [1,2] else 2
		check("papel P1/P2 preservado após viagem",level.get(KEYS[phase+1])==expected)
	await shot("hud-cinco-cristais")
	level.crystal_count=1;await frames(20);level.get_node("GameScreens").adventure_hud.sync()
	check("emblema completo tem seis cristais únicos",get_meta("friendship_crystals").size()==6)
	await shot("hud-seis-cristais")
	await fresh("res://level_6.tscn",1,KEYS[6]);await frames(20)
	check("reinício não inventa cristal da fase, preserva registro da sessão",level.crystal_count==0 and get_meta("friendship_crystals").size()==6)
	await finish("HUD e vinhetas: estados isolados e responsividade")
