extends "res://tests/journey_driver.gd"
## Percurso com entradas; nenhuma posição ou solução é injetada nesta rotina.
func run() -> void:
	root.size=viewport_size
	for slot in ([1] if "--single" in OS.get_cmdline_user_args() else [1,2]):
		await fresh("res://level_5.tscn",slot,"lead_player_id")
		var a: CoopPlayer=level.marceline;var b: CoopPlayer=level.cake
		await capture("tower-start")
		check("dupla segura",a.is_on_floor() and b.is_on_floor())
		await walk(a,360);await tap(a,"interact")
		check("primeiro receptor",level.solved[0])
		await walk(b,675);await tap(b,"interact");await walk(b,780);await tap(b,"interact")
		check("Cake rasteja e ajusta desvio",b.crawling and level.mirrors[1].orientation==1)
		await walk(a,620);await jump(a,670);await jump(a,744);await walk(a,830);await jump(a,928,true)
		await tap(a,"interact")
		check("galeria cooperativa",level.solved[1])
		await capture("tower-gallery")
		await walk(b,1205);await walk(a,1205);await frames(10)
		check("checkpoint conquistado",level.checkpoint_active)
		await walk(b,1275);await tap(b,"interact");await walk(b,1400);await tap(b,"interact")
		await walk(a,1220);await jump(a,1270);await jump(a,1350);await walk(a,1435);await jump(a,1568,true)
		await tap(a,"interact")
		check("dois receptores finais",level.solved[2])
		await capture("tower-final-light")
		await walk(b,1940);await walk(a,1940)
		await walk(a,2110)
		check("saída exige a parceira",level.completion_count==0)
		await walk(b,2110);await frames(15)
		check("conclusão conjunta sem recuperação",level.completion_count==1 and level.recovery_count==0)
		await capture("tower-complete")
		for child in level.hud.get_children():
			if child is Button and child.text.begins_with("Continuar"):child.pressed.emit();break
		await frames(40);level=current_scene
		check("ligação com fase 6 preserva papel do primeiro jogador",level.scene_file_path=="res://level_6.tscn" and level.pair[0].player_id==slot)
	await finish("Torre dos Espelhos - percurso real por entradas")
