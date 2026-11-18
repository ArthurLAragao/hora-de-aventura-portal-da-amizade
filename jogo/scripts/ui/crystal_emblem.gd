extends Control
## Cristais da HUD: atlas de oito poses e efeito de aquisição; não concede progresso.
const ART=preload("res://scripts/ui/sprite_art.gd")
const COLORS=ART.COLORS
var acquired: Array=[]
var pulses: Dictionary={}
var clock:=0.0
var compact:=true
var gems: Array[AnimatedSprite2D]=[]
var effects: Array[AnimatedSprite2D]=[]

func _ready() -> void:
	mouse_filter=MOUSE_FILTER_IGNORE;texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	for i in 6:
		var at:=Vector2(24+i*42,24) if compact else Vector2(70+cos(TAU*i/6-PI/2)*52,70+sin(TAU*i/6-PI/2)*52)
		var gem:=ART.gem(self,at,COLORS[i],0.76 if compact else 1.0);gem.name="Crystal%d"%(i+1);gem.frame=i%8;gem.hide();gems.append(gem)
		var effect:=ART.burst(self,at,COLORS[i],0.8 if compact else 1.0);effect.hide();effects.append(effect)
	refresh()

## Mantém a API da HUD e dispara o atlas somente para cristais recém-adquiridos.
func set_crystals(values: Array) -> void:
	for n in values:
		if not n in acquired:
			pulses[n]=1.0
			if effects.size()==6 and n>=1 and n<=6:effects[n-1].show();effects[n-1].play(&"activate")
	acquired=values.duplicate();refresh()

func refresh() -> void:
	for i in gems.size():gems[i].visible=i+1 in acquired

## Somente a ênfase breve usa escala; a rotação permanece nos frames do atlas.
func _process(delta: float) -> void:
	clock+=delta
	for n in pulses.keys():pulses[n]=maxf(0,pulses[n]-delta*0.8)
	for i in gems.size():gems[i].scale=Vector2.ONE*(0.76 if compact else 1.0)*(1.0+0.12*float(pulses.get(i+1,0.0)))
