extends "res://tests/journey_driver.gd"
## Testa apresentação; posições preparadas abaixo apenas expõem prompts, não concluem percursos.
const ROLES={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}

## Confere os elementos de tutorial sem ocultar pistas, símbolos, painéis ou conversas.
func audit(node: Node) -> bool:
	var okay:=true
	if node.has_meta("tutorial_hidden"):okay=node.visibility_layer==0
	for child in node.get_children():okay=audit(child) and okay
	return okay

## Verifica a renderização limpa em cada fase e a permanência do comportamento funcional.
func run() -> void:
	root.size=viewport_size
	for slot in [1,2]:
		for number in range(1,7):
			await fresh("res://level_%d.tscn"%number,slot,ROLES[number])
			var story=level.get_node("FriendshipStory")
			check("F%d: diálogos continuam visíveis sem legenda de comandos"%number,story.card.visible and story.card.visibility_layer!=0 and not story.footer.visible)
			check("F%d: camada de tutorial desativada"%number,audit(level))
			await capture("clean-f%d-start"%number)
			if number==1:
				check("HUD e ajuda automática removidos",level.hud.get_node("Status").visibility_layer==0 and level.hud.get_node("HelpHint").visibility_layer==0)
				level.jake.position=Vector2(640,376);await frames(20)
				# O circuito inicial ainda não foi resolvido nesta fixture. Simula apenas atualização visual.
				level.bridge.approach_hint.text="Shift direito: ponte de Jake";level.bridge.approach_hint.show()
				check("texto da ponte continua oculto após atualização visual",level.bridge.approach_hint.visibility_layer==0)
				await capture("clean-bridge-offer")
			if number==3:
				check("pista musical permanece desenhável",level.get_node("MusicalClue").visibility_layer==1)
				level.bmo.position=Vector2(1050,352);await frames(12);await tap(level.bmo,"interact")
				check("terminal mantém seleção progresso e controles do painel",level.symbol_terminal.panel_open and level.symbol_terminal.progress.visibility_layer==1 and level.symbol_terminal.help.visibility_layer==1)
				await capture("clean-terminal")
			if number==4:
				level.finn.position=Vector2(1432,352);await frames(12)
				check("comandos de giro do circuito ficam fora do cenário",level.connections.indicators.all(func(label):return label.visibility_layer==0))
			if number==5:
				var symbols:=0
				for child in level.get_children():
					if child is Label and child.text in ["◇","○","△","□"] and child.visibility_layer==1:symbols+=1
				check("quatro símbolos dos receptores preservados",symbols==4)
				check("prompts dinâmicos dos espelhos removidos",level.mirrors.all(func(m):return m.prompt.visibility_layer==0))
			if number==6:
				level._repair(0);level._advance_pair(1);await until(func():return not level._transitioning,180);await frames(16)
				check("troca de dupla mantém fala e oculta dicas da área",story.current_id=="pair1" and story.card.visible and level.get_node("SwitchPrompt").visibility_layer==0)
				await capture("clean-portal-pair")
	await finish("Apresentação limpa: tutoriais e conteúdo preservado")
