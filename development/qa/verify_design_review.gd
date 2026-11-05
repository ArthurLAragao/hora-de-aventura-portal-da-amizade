extends "res://tests/journey_driver.gd"
## Casos isolados de regressão; não são usados como prova de percurso normal.
func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:
		for number in [3,4,5]:
			await fresh("res://level_%d.tscn"%number,slot,"lead_player_id")
			var crystal=level.get_node("FriendshipCrystal")
			crystal._on_body_entered(get_nodes_in_group("players")[0])
			crystal.collect_sfx.stop();crystal.collect_sfx.finished.emit()
			await frames(8)
			var story=level.get_node("FriendshipStory")
			check("F%d: diálogo preserva coleta após remover cristal"%number,not level.has_node("FriendshipCrystal") and story.snapshot().crystal)
			await frames(30)
		await fresh("res://level_5.tscn",slot,"lead_player_id")
		await walk(level.marceline,360);await tap(level.marceline,"interact")
		check("primeiro espelho não é operado do piso inferior",not level.solved[0])
		await walk(level.marceline,280);await jump(level.marceline,344);await tap(level.marceline,"interact")
		check("balcão permite ajustar o primeiro feixe",level.solved[0])
		var panorama: Sprite2D=level.get_node("Background/Panorama")
		var bounds:=Rect2(panorama.position-panorama.texture.get_size()*panorama.scale*0.5,panorama.texture.get_size()*panorama.scale)
		check("fundo da torre cobre os limites da câmera",bounds.encloses(Rect2(0,0,2208,648)))
		for size in [Vector2i(1280,720),Vector2i(1920,1080)]:
			root.size=size;await frames(6)
			check("torre mantém perfil legível em %s"%size,root.content_scale_size==Vector2i(1152,648))
	await finish("Revisão de design: coleta persistente, balcão e cobertura da torre")
