extends "res://scripts/ui/phase_hud.gd"
## Presentation shared only by the imported cave/workshop scenes.
var help_panel: PanelContainer
var title: Label
var region := 3

## Prepara o componente antes da entrada de seus filhos na árvore. Contexto: interface das fases integradas.
func _enter_tree() -> void:
	if not has_node("JakeBridgeHint"):
		var unused:=Label.new();unused.name="JakeBridgeHint";unused.hide();add_child(unused)

## Prepara as referências e o estado deste componente ao entrar na árvore. Contexto: interface das fases integradas.
func _ready() -> void:
	super._ready()
	region=3 if get_parent().has_node("MusicPanel") else 4
	$HUDBackplate.size=Vector2(570,96)
	title=Label.new();title.position=Vector2(16,10)
	title.text="CAVERNA MUSICAL" if region==3 else "OFICINA DO REINO DOCE"
	title.add_theme_font_size_override("font_size",14);add_child(title)
	hint_label.position=Vector2(16,34);hint_label.size=Vector2(540,28)
	hint_label.add_theme_font_size_override("font_size",16)
	crystal_label.position=Vector2(16,66);crystal_label.add_theme_font_size_override("font_size",13)
	var help:=Button.new();help.text="Controles";help.position=Vector2(900,12);help.size=Vector2(110,32)
	add_child(help)
	var back:=Button.new();back.text="Fases";back.position=Vector2(1020,12);back.size=Vector2(110,32)
	back.pressed.connect(_return_to_phase_select);add_child(back)
	help_panel=PanelContainer.new();help_panel.position=Vector2(580,54);help_panel.hide();add_child(help_panel)
	var instructions:=Label.new();instructions.text=("Marceline P1: A/D, Espaço/W, E, Q" if region==3 else "Finn P1: A/D, Espaço/W, E; R restaura tronco")+"\nBMO P2: setas, Cima, Enter\nTerminal: setas escolhem; Enter confirma.\nEsc: cancelar | F2: reiniciar"
	instructions.add_theme_font_size_override("font_size",14);help_panel.add_child(instructions)
	help.pressed.connect(func():help_panel.visible=not help_panel.visible)

## Atualiza a lógica/apresentação deste componente a cada quadro. Contexto: interface das fases integradas.
func _process(_delta: float) -> void:
	var level:=get_parent()
	var lead: int=level.lead_player_id
	var actor_name: String="Marceline" if region==3 else "Finn"
	var help_text: String=actor_name+" P%d • BMO P%d\n"%[lead,3-lead]+"P1: A/D, Espaço/W, E, Q\nP2: setas, Cima, Enter, Shift direito\nTerminal: mover escolhe; interação confirma.\nEsc: cancelar | F2: reiniciar"
	if help_panel!=null:help_panel.get_child(0).text=help_text
	if level.completion_count>0:
		hint_label.text="Cristal recuperado. Caminho concluído!"
		return
	if region==3:
		if not level.get_node("MusicGate").is_open:hint_label.text="Marceline: toque no painel musical."
		elif not level.symbol_terminal.solved:hint_label.text="BMO: reproduza a sequência da pista."
		elif not level.energy_terminal.energized:hint_label.text="BMO: conecte a energia."
		elif not level.get_node("RegionalLayout").confirmation_solved:hint_label.text="Toquem juntos as duas placas. Depois, o cristal."
		else:hint_label.text="Recuperem o cristal e sigam juntos."
	else:
		if not level.carrier.arrived:hint_label.text="Finn: carregue o bloco. BMO: mova a plataforma."
		elif not level.get_node("TrunkPuzzle/Gate").is_open:hint_label.text="Finn: leve o bloco até a placa."
		elif not level.connections.solved():hint_label.text="Finn: alinhe os tubos. BMO: conecte a energia."
		elif not level.energy_terminal.energized:hint_label.text="BMO: conecte a energia da oficina."
		else:hint_label.text="Recuperem o cristal e sigam juntos."

## Mostra o estado de conclusão e as opções de fluxo disponíveis.
func show_completion() -> void:
	super.show_completion()
	# One completion presentation; the shared exit's world label would be clipped.
	get_parent().get_node("CooperativeExit/Completion").hide()
