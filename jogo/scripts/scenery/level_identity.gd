extends Node2D
## Acabamento local das seis regiões: arquitetura de fundo e leitura de causa/efeito.
## Não cria colisões nem altera personagens; todas as medidas estão em unidades do mundo.
@export_range(1,6) var phase:=1
var level: Node2D
var previous_state:=""
var saved_window: Array=[]
var backdrop: Node2D

## Prepara a camada e corrige apenas o enquadramento local da Torre dos Espelhos.
func _ready() -> void:
	level=get_parent();z_index=1;texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop=Node2D.new();backdrop.name="ArquiteturaDistante";backdrop.z_index=-3
	add_child(backdrop);backdrop.draw.connect(draw_backdrop)
	configure.call_deferred()

## Aguarda construtores de fase que montam suas referências no _ready da raiz.
func configure() -> void:
	if phase==5:
		var window=get_window()
		saved_window=[window.content_scale_size,window.content_scale_mode,window.content_scale_aspect]
		window.content_scale_size=Vector2i(1152,648)
		window.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
		# A pintura conserva proporção. Seu fundo deve cobrir os limites completos da câmera.
		var panorama: Sprite2D=level.get_node("Background/Panorama")
		var ratio:=maxf(2208.0/panorama.texture.get_width(),648.0/panorama.texture.get_height())
		panorama.scale=Vector2.ONE*ratio;panorama.position=Vector2(1104,324)
	queue_redraw()

## Só redesenha os vínculos ao mudar uma conquista, sem reconstruir decoração por quadro.
func _process(_delta: float) -> void:
	var state:=""
	match phase:
		1:state=str(level.tutorial_solved)+str(level.relay_solved)
		2:state=str(level.first_unlocked)+str(level.crank.solved)
		3:state=str(level.symbol_terminal.solved)+str(level.energy_terminal.energized)
		4:state=str(level.carrier.arrived)+str(level.energy_terminal.energized)
		5:state=str(level.solved)
		6:state=str(level.repaired)
	if state!=previous_state:previous_state=state;queue_redraw()

## Desenha uma escora de madeira atrás do percurso; não sugere um degrau adicional.
func brace(x: float,y: float,height: int) -> void:
	draw_rect(Rect2(x-3,y-height,6,height),Color("514535"))
	draw_rect(Rect2(x-1,y-height+2,2,height-2),Color("947447"))
	for dy in [12,height-8]:draw_rect(Rect2(x-4,y-dy,8,3),Color("3d4f4a"))

## Desenha um arco escalonado de fundo, sem chão ou plataformas fictícias.
func arch(x: int,y: int,width: int,height: int,stone: Color,edge: Color) -> void:
	for side in [x,x+width-10]:
		backdrop.draw_rect(Rect2(side,y-height+24,10,height-24),stone)
		backdrop.draw_rect(Rect2(side+2,y-height+26,2,height-28),edge)
		for dy in range(16,height-20,20):backdrop.draw_rect(Rect2(side,y-dy,10,2),stone.darkened(0.22))
	for spec in [[x+8,y-height+16,8,10],[x+14,y-height+8,12,10],[x+24,y-height,width-48,10],[x+width-26,y-height+8,12,10],[x+width-16,y-height+16,8,10]]:
		backdrop.draw_rect(Rect2(spec[0],spec[1],spec[2],spec[3]),stone)
		backdrop.draw_rect(Rect2(spec[0],spec[1],spec[2],2),edge)

## Liga discretamente mecanismo e resultado por encaixes sob o piso, usando ritmo e luz.
func conduit(x: int,end_x: int,y: int,active: bool,tint: Color) -> void:
	for at in range(x,end_x,12):
		draw_rect(Rect2(at,y,8,4),Color("243540"))
		draw_rect(Rect2(at+1,y+1,6,1),tint if active else tint.darkened(0.45))
		if active:draw_rect(Rect2(at+3,y+2,2,1),Color("e2dfb3"))

## Compõe marcos exclusivos por ambiente, deixando mecanismos e silhuetas livres.
func _draw() -> void:
	if level==null:return
	match phase:
		1:
			# Varanda e escoras sob a trilha conectam a casa à construção dos amigos.
			for spec in [[60,402],[196,402],[1144,362],[1212,362],[2188,362],[2384,362]]:
				brace(spec[0],spec[1]+68,68)
			for span in [[48,208,402],[1128,1228,362],[2172,2400,362]]:
				draw_rect(Rect2(span[0],span[2]+18,span[1]-span[0],5),Color("69563b"))
			conduit(1456,1688,381,level.top_plate.is_active() or level.relay_solved,Color("92b99a"))
			# Juntas do percurso superior, abaixo dos pés e sem esconder a placa de Jake.
			for x in range(1548,1920,48):draw_rect(Rect2(x,292,24,3),Color("7b6850"))
		2:
			# Antigo aqueduto congelado, com arcos enquadrando o bosque e o reencontro.

			for x in [436,612]:
				draw_rect(Rect2(x,458,4,39),Color("78a8c1"))
				draw_rect(Rect2(x,458,8,3),Color("dcf1ee"))
			conduit(656,744,537,level.first_unlocked,Color("99cdd1"))
		3:
			# Ressonadores e nervuras ligam painel, memória e galeria musical.
			for x in [48,868,1176,1872]:
				draw_rect(Rect2(x,386,40,8),Color("343e62"))
				for i in 3:
					var height:=32+i*12
					draw_rect(Rect2(x+6+i*10,386-height,6,height),Color("465b78"))
					draw_rect(Rect2(x+7+i*10,388-height,2,height-2),Color("8297ac"))
			conduit(1080,1200,413,level.symbol_terminal.solved,Color("a8c3cf"))
		4:
			# Treliças da oficina e trilho preso à fundação; espaço livre para o carregamento.

			for x in range(448,704,24):
				draw_rect(Rect2(x,456,16,4),Color("5e4c60"))
				draw_rect(Rect2(x+4,460,4,18),Color("8a7278"))
			conduit(720,824,409,level.carrier.arrived,Color("e5c58e"))
		5:
			# Galeria contínua: contrafortes e fundação dão volume sem ocultar feixes.

			draw_rect(Rect2(257,400,6,100),Color("564c69"))
			draw_rect(Rect2(254,496,12,4),Color("9d8a84"))
			draw_rect(Rect2(358,404,4,48),Color("746784"))
			for x in range(16,2208,32):
				draw_rect(Rect2(x,538,20,4),Color("60516e"))
				draw_rect(Rect2(x+4,544,12,6),Color("443d56"))
			for span in [[320,396,0],[744,852,1],[1360,1488,2]]:
				conduit(span[0],span[1],522,level.solved[span[2]],Color("d1c5a0"))
		6:
			# Pares de pilares enquadram o santuário; o núcleo continua com maior contraste.

			for i in 3:
				conduit(624+i*42,660+i*42,492,level.repaired[i],Color("94c7b3"))

## Mantém a arquitetura distante atrás de plataformas e mecanismos móveis.
func draw_backdrop() -> void:
	match phase:
		2:
			for spec in [[32,519,152,188],[1008,519,144,176],[1784,519,144,188],[2128,487,128,160]]:
				arch(spec[0],spec[1],spec[2],spec[3],Color("436a86"),Color("99bdcc"))
		4:
			for x in [32,864,1168,1792,2112]:
				arch(x,388,80,168,Color("82636c"),Color("d4ac82"))
		5:
			for spec in [[24,500,144,294],[424,500,112,294],[1056,500,80,244],[1840,500,128,294],[2048,500,112,294]]:
				arch(spec[0],spec[1],spec[2],spec[3],Color("39384e"),Color("80718e"))
		6:
			for spec in [[32,508,112,172],[1136,476,144,172]]:
				arch(spec[0],spec[1],spec[2],spec[3],Color("365464"),Color("71928d"))

## Devolve o perfil de janela anterior ao sair da Torre; não altera project.godot.
func _exit_tree() -> void:
	if saved_window.is_empty():return
	var window=get_window()
	if is_instance_valid(window):
		window.content_scale_size=saved_window[0]
		window.content_scale_mode=saved_window[1]
		window.content_scale_aspect=saved_window[2]
