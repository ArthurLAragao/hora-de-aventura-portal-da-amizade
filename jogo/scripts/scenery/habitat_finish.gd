extends Node2D
## Composição regional: fundações, flora agrupada e planos de contraste.
## Nenhum corpo, área, superfície de apoio ou regra de puzzle é criado aqui.
@export_range(2,5) var phase:=2
var level: Node2D
var distant: Node2D
var foundation: Node2D
var columns: Array[int]=[]
var floor_y:=519
var lights: Array[Sprite2D]=[]
var time:=0.0
var body_texture: Texture2D
const ART="res://Assets/02_Environments/"
const REGIONS={2:"02_ice_kingdom",3:"03_musical_cave",4:"04_candy_workshop",5:"05_mirror_tower"}

## Espera o layout da fase e suas lacunas serem criados antes de posicionar o acabamento.
func _ready() -> void:
	level=get_parent();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	configure.call_deferred()

## Usa as células efetivamente existentes: decoração nunca preenche visualmente um vão.
func configure() -> void:
	await get_tree().process_frame
	floor_y={2:519,3:394,4:388,5:500}[phase]
	body_texture=load(ART+REGIONS[phase]+"/tiles/fill.png")
	var map=level.get_node_or_null("Terrain" if phase==2 else "TileMapLayer")
	if map!=null:
		var row:=16 if phase==2 else 12
		for x in range(72 if phase==2 else 68):
			var source: int=map.get_cell_source_id(0,Vector2i(x,row)) if map is TileMap else map.get_cell_source_id(Vector2i(x,row))
			if source>=0:columns.append(x)
	else:
		for x in 69:columns.append(x)
	distant=Node2D.new();distant.name="EstruturasAoFundo";distant.z_index=-4;add_child(distant);distant.draw.connect(draw_distance)
	foundation=Node2D.new();foundation.name="Fundacoes";foundation.z_index=2;add_child(foundation);foundation.draw.connect(draw_foundations)
	var panorama=level.get_node_or_null("Background" if phase==2 else "Background/Panorama" if phase==5 else "BackgroundParallax/BackgroundPanorama")
	if panorama is Sprite2D:panorama.self_modulate={2:Color("c1d8e3"),3:Color("a7a3c4"),4:Color("d5bdc1"),5:Color("c2bdcf")}[phase]
	# Os antigos arcos finos não competem mais com a arquitetura regional final.
	var identity=level.get_node_or_null("LevelIdentity/ArquiteturaDistante")
	if identity!=null:identity.hide()
	build_groups()

## Agrupa flora nativa nas margens dos ambientes, mantendo áreas de mecanismo livres.
func build_groups() -> void:
	var groups: Array={2:[[72,519],[256,519],[1000,519],[1824,519],[2224,519]],3:[[72,394],[904,394],[1152,394],[2120,394]],4:[[80,388],[864,388],[1792,388],[2140,388]],5:[[60,500],[620,500],[1104,500],[1864,500],[2160,500]]}[phase]
	for group in groups:
		for index in 3:
			var asset: String=ART+REGIONS[phase]+"/tiles/decor_%02d.png"%(1+index)
			var sprite:=Sprite2D.new();sprite.texture=load(asset);sprite.z_index=-2
			# Retângulo opaco consultado apenas na montagem, não durante o movimento.
			var used:=sprite.texture.get_image().get_used_rect()
			sprite.position=Vector2(group[0]+(index-1)*18,group[1]-(used.end.y-sprite.texture.get_height()*0.5))
			sprite.modulate=Color("acbed0") if phase in [2,5] else Color("9aa6bf") if phase==3 else Color("d9c5ad")
			add_child(sprite)
			if index==2 and phase==3:lights.append(sprite)

## Massas contínuas sob o piso: veios de gelo, estratos de caverna e alvenaria estrutural.
## Cada faixa é limitada pelas colunas existentes; nenhuma lacuna recebe chão decorativo.
func draw_foundations() -> void:
	var colors: Array={2:[Color("244b68"),Color("477b97"),Color("8bb7c8")],3:[Color("292b43"),Color("44415c"),Color("6b6585")],4:[Color("654453"),Color("916776"),Color("c6978b")],5:[Color("363148"),Color("57506b"),Color("887b99")]}[phase]
	var bottom: int={2:672,3:512,4:512,5:640}[phase]
	var top:=floor_y+26
	for column in columns:
		for y in range(top,bottom,32):
			var height:=mini(32,bottom-y)
			foundation.draw_texture_rect_region(body_texture,Rect2(column*32,y,32,height),Rect2(0,0,32,height))
	# O relevo amplo tinge a textura original: preserva granulação, paleta e densidade de pixels.
	colors[1].a=0.38
	colors[2].a=0.58
	var begin:=0
	while begin<columns.size():
		var end:=begin+1
		while end<columns.size() and columns[end]==columns[end-1]+1:end+=1
		var left:=columns[begin]*32;var right: int=(columns[end-1]+1)*32
		if phase in [2,3]:
			# Facetas largas com bordas em degraus substituem a antiga malha de pedras idênticas.
			for x in range(left,right,96):
				var width:=mini(96,right-x)
				var depth:=bottom-top-12-posmod(x/32,3)*7
				var inset:=mini(12,width/3)
				var face:=PackedVector2Array([Vector2(x,top),Vector2(x+width,top),Vector2(x+width,top+depth-18),Vector2(x+width-inset,top+depth-18),Vector2(x+width-inset,top+depth),Vector2(x+inset,top+depth),Vector2(x+inset,top+depth-8),Vector2(x,top+depth-8)])
				foundation.draw_colored_polygon(face,colors[1].darkened(posmod(x/32,3)*0.045))
				foundation.draw_rect(Rect2(x,top,width,3),colors[2].darkened(0.18))
				if phase==2:
					# Cristal de gelo estriado; brilho opaco, sem parecer plataforma adicional.
					for dx in range(7,width-3,19):
						var height:=depth-12-posmod(x+dx,27)
						foundation.draw_rect(Rect2(x+dx,top+9,3,height),colors[2].darkened(0.18))
						foundation.draw_rect(Rect2(x+dx+3,top+18,2,maxi(2,height-20)),colors[0].lightened(0.05))
				else:
					# Camadas horizontais interrompidas por fissuras, como a rocha do fundo.
					for row in 3:
						var y:=top+18+row*23
						var split:=mini(width-3,12+posmod(x+row*29,maxi(1,width-18)))
						foundation.draw_rect(Rect2(x,y,split,2),colors[0])
						foundation.draw_rect(Rect2(x+split,y,2,7),colors[0])
						foundation.draw_rect(Rect2(x+split,y+7,width-split,2),colors[0])
						foundation.draw_rect(Rect2(x+4,y-2,maxi(1,split-8),1),colors[2].darkened(0.25))
		else:
			# Blocos largos e juntas desencontradas, com base escura em vez de grade uniforme.
			for row in 3:
				var y:=top+row*32
				for x in range(left-32*(row%2),right,64):
					var a:=maxi(x,left);var b:=mini(x+62,right)
					if b<=a:continue
					foundation.draw_rect(Rect2(a,y,b-a,29),colors[1].darkened(row*0.07))
					foundation.draw_rect(Rect2(a,y,b-a,2),colors[2].darkened(row*0.12))
					foundation.draw_rect(Rect2(a+2,y+3,1,23),colors[2].darkened(0.3))
					foundation.draw_rect(Rect2(a+6,y+19,mini(14,b-a-6),2),colors[0].lightened(0.04))
			for x in range(left+24,right-8,160):
				foundation.draw_rect(Rect2(x,top,8,bottom-top),colors[0])
				foundation.draw_rect(Rect2(x+2,top,3,bottom-top-4),colors[2].darkened(0.18))
		foundation.draw_rect(Rect2(left,bottom-4,right-left,4),colors[0])
		begin=end

## Nervuras grandes enquadram conjuntos; todas ficam atrás de personagens e plataformas.
func draw_distance() -> void:
	match phase:
		2:
			for x in [40,960,1808,2160]:
				pier(x,519,124,Color("41667d"),Color("a9c7d1"))
				for dx in [0,36,72]:
					distant.draw_rect(Rect2(x+dx-12,411,28,7),Color("b8d8dd"))
					distant.draw_rect(Rect2(x+dx+6,418,3,14+posmod(dx,13)),Color("83afc8"))
		3:
			for spec in [[32,88],[832,66],[1152,92],[1888,70],[2112,84]]:
				var x: int=spec[0];var height: int=spec[1]
				for step in range(ceili(height/12.0)):
					distant.draw_rect(Rect2(x-step*3,floor_y-height+step*12,18+step*7,height-step*12),Color("343751"))
				for step in 4:distant.draw_rect(Rect2(x+3+step*2,floor_y-height+8+step*12,3,11),Color("64798b"))
		4:
			for x in [32,856,1752,2080]:
				pier(x,388,138,Color("725568"),Color("ceab92"))
				# Tanques de fundo: silhueta arredondada em degraus, sem aparentar novo terminal.
				distant.draw_rect(Rect2(x+12,254,40,12),Color("ba9b90"))
				distant.draw_rect(Rect2(x+8,266,48,86),Color("876a7c"))
				for y in [270,328]:distant.draw_rect(Rect2(x+6,y,52,5),Color("c29d8b"))
				distant.draw_rect(Rect2(x+17,279,6,43),Color("ad8d9a"))
		5:
			for x in [16,432,1080,1840,2112]:
				pier(x,500,244,Color("49435c"),Color("a393ad"))
				# Bandeiras presas à verga; contorno discreto, sem cobrir o trajeto dos raios.
				distant.draw_rect(Rect2(x+18,270,36,4),Color("bfa67c"))
				distant.draw_rect(Rect2(x+22,274,28,68),Color("62566f"))
				for step in 5:distant.draw_rect(Rect2(x+22+step*3,342+step*3,28-step*6,3),Color("62566f"))
				distant.draw_rect(Rect2(x+34,286,4,38),Color("a392ad"))

## Um contraforte com base, fuste, juntas e capitel, sem colisão decorativa.
func pier(x: int,y: int,height: int,dark: Color,light: Color) -> void:
	for dx in [0,64]:
		distant.draw_rect(Rect2(x+dx,y-height,16,height),dark)
		distant.draw_rect(Rect2(x+dx+3,y-height+4,3,height-4),light.darkened(0.2))
		for dy in range(0,height,28):distant.draw_rect(Rect2(x+dx,y-dy,16,2),dark.darkened(0.35))
		distant.draw_rect(Rect2(x+dx-4,y-8,24,8),dark)
		distant.draw_rect(Rect2(x+dx-4,y-8,24,2),light)
	distant.draw_rect(Rect2(x-4,y-height,88,8),dark)
	distant.draw_rect(Rect2(x-4,y-height,88,2),light)

## Um único pulso lento nas plantas minerais, sem partículas nem movimento de colisão.
func _process(delta: float) -> void:
	if lights.is_empty():return
	time+=delta
	for i in lights.size():
		var shade:=0.92+0.08*sin(time*0.8+i*1.7)
		lights[i].self_modulate=Color(shade,shade,shade)
