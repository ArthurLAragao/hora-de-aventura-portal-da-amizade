extends "res://tests/journey_driver.gd"
## Fixtures de tentativas inválidas; preparar posições não é evidência de travessia.
func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:
		for gap in [[724,928],[1492,1696]]:
			await fresh("res://level_2.tscn",slot,"cake_player_id")
			level.fionna.position=Vector2(gap[0],487);level.cake.position=Vector2(gap[0]-72,487);await frames(12)
			var before: int=level.recovery_count
			Input.action_press(action(level.fionna,"right"));await frames(5)
			Input.action_press(action(level.fionna,"jump"));await frames(2);Input.action_release(action(level.fionna,"jump"))
			await until(func():return level.recovery_count>before,160);release();await frames(10)
			check("2: salto com margem de borda não substitui passagem %d"%gap[1],level.recovery_count>before and not level.first_crank.solved and not level.crank.solved)
			await fresh("res://level_2.tscn",slot,"cake_player_id")
			level.cake.position=Vector2(gap[0],487);level.fionna.position=Vector2(gap[0]-72,487);await frames(12)
			Input.action_press(action(level.cake,"right"));await frames(5)
			Input.action_press(action(level.cake,"jump"));await frames(2);Input.action_release(action(level.cake,"jump"))
			await until(func():return level.recovery_count>0,160);release();await frames(10)
			check("2: Cake também não salta o vão %d"%gap[1],level.recovery_count>0 and not level.first_crank.solved and not level.crank.solved)
		check("2: só a âncora gelada recebe extensão adicional",level.anchor.extra_length==96 and level.anchor.support.get_child(0).polygon[1].x==208)
		await fresh("res://level_3.tscn",slot,"lead_player_id")
		level.marceline.position=Vector2(512,247.5);await frames(12)
		Input.action_press(action(level.marceline,"jump"));Input.action_press(action(level.marceline,"right"));await frames(3);Input.action_release(action(level.marceline,"jump"));Input.action_press(action(level.marceline,"ability"));await frames(110);release()
		check("3: flutuação não passa por cima do portão musical fechado",level.marceline.position.x<700 and not level.get_node("MusicGate").is_open and not level.get_node("Checkpoint").activated)
		level.bmo.position=Vector2(1190,362);level.marceline.position=Vector2(1100,362);await frames(12)
		Input.action_press(action(level.bmo,"jump"));Input.action_press(action(level.bmo,"right"));await frames(3);Input.action_release(action(level.bmo,"jump"));await frames(90);release()
		check("3: terminal não pode ser ignorado saltando o portão",level.bmo.position.x<1260 and not level.symbol_terminal.solved)
		await fresh("res://level_4.tscn",slot,"lead_player_id")
		level.finn.position=Vector2(1216,311.5);await frames(15)
		check("4: terceiro encaixe alcançável sobre apoio visível",level.finn.is_on_floor() and level.finn.position.y<330)
		await tap(level.finn,"interact");await tap(level.finn,"interact")
		check("4: terceira peça responde e não resolve as outras",level.connections.turns==[1,3,0] and not level.connections.solved())
		await fresh("res://level_5.tscn",slot,"lead_player_id")
		level.emitters.assign([{"at":Vector2(360,440),"dir":Vector2.UP,"sector":0}]);level.mirrors[0].orientation=0;level.refresh_light()
		check("5: verso do espelho interrompe raio sem ativar receptor",level.beams.size()==1 and level.beams[0][1].is_equal_approx(Vector2(360,394)) and not level.receivers[0].active)
		level.emitters.assign([{"at":Vector2(260,394),"dir":Vector2.RIGHT,"sector":0}]);level.refresh_light()
		check("5: face refletora corresponde ao feixe correto",level.receivers[0].active)
		level.mirrors[4].orientation=1;level.mirrors[5].orientation=1
		level.emitters.assign([{"at":Vector2(1400,480),"dir":Vector2.DOWN,"sector":2},{"at":Vector2(1620,488),"dir":Vector2.UP,"sector":2}]);level.refresh_light()
		check("5: receptor inferior sozinho não abre final",level.receivers[2].active and not level.receivers[3].active and not level.solved[2])
		level.mirrors[5].orientation=0;level.refresh_light()
		check("5: ambos os ajustes válidos abrem a saída",level.receivers[2].active and level.receivers[3].active and level.solved[2])
	await finish("Revisão manual: atalhos, frente dos espelhos e alcance dos mecanismos")
