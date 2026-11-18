extends "res://tests/journey_driver.gd"
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
const GUIDE="res://Assets/04_Interface/Godot/instructions.tscn"
func screen(path: String) -> void:
	release()
	if is_instance_valid(level):stop_test_audio(level);level.queue_free();await frames(4)
	level=load(path).instantiate();root.add_child(level);current_scene=level;await frames(20)
func send_key(code: Key,pressed: bool,location:=KEY_LOCATION_UNSPECIFIED) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=pressed;event.location=location
	Input.parse_input_event(event);await frames(3)
func run() -> void:
	root.size=Vector2i(1280,720);PROGRESS.reset()
	check("save novo libera somente fase 1",PROGRESS.unlocked(1) and not PROGRESS.unlocked(2) and not PROGRESS.unlocked(6))
	PROGRESS.collect(1);check("coletar sem concluir não libera fase 2",not PROGRESS.unlocked(2) and PROGRESS.read().crystals==[1])
	PROGRESS.complete(1);PROGRESS.complete(1);root.remove_meta("campaign_cache");root.remove_meta("campaign_cache_path")
	check("save recarregado é idempotente e libera fase 2",PROGRESS.read().completed==[1] and PROGRESS.unlocked(2) and not PROGRESS.unlocked(3))
	PROGRESS.complete(6);check("F6 isolada não pula a sequência",not PROGRESS.unlocked(3) and not PROGRESS.restore_world())
	await screen("res://phase_select.tscn")
	check("cartões refletem bloqueio real",not level.cards[0].disabled and not level.cards[1].disabled and level.cards[2].disabled and level.cards[5].disabled)
	level.open_phase(3);await frames(3);check("chamada de fase bloqueada também é recusada",current_scene==level)
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(4)
		check("seletor cabe em %s"%size,Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(level._design.get_global_rect()))
		await capture("destinations-%dx%d"%[size.x,size.y])
	await screen(GUIDE)
	check("teclado completo e apenas retorno na navegação",level.key_count==104 and level.back!=null and level.design.get_children().filter(func(n):return n is Button and n.focus_mode!=Control.FOCUS_NONE).size()==1)
	await send_key(KEY_A,true);check("A físico anima andar do P1",level.active.has(KEY_A) and level.demo_action[0]=="Andar" and level.keys[KEY_A].button_pressed)
	await frames(40);check("tecla segurada mantém destaque e caminhada",level.keys[KEY_A].button_pressed and level.demos[0].animation==&"walk")
	await send_key(KEY_A,false);await frames(45);check("soltar tecla restaura repouso",not level.keys[KEY_A].button_pressed and level.demos[0].animation==&"idle")
	await send_key(KEY_SHIFT,true,KEY_LOCATION_RIGHT);check("Shift direito pertence ao P2",level.demo_action[1]=="Poder" and level.active.has(KEY_SHIFT+1000));await send_key(KEY_SHIFT,false,KEY_LOCATION_RIGHT)
	level.keys[KEY_UP].button_down.emit();level.keys[KEY_UP].button_up.emit();check("clique em seta anima salto do P2",level.demo_action[1]=="Pular")
	check("guia não injeta ações de movimento",not Input.is_action_pressed("p1_left") and not Input.is_action_pressed("p2_jump"))
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(4);check("teclado cabe em %s"%size,Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(level.design.get_global_rect()));await capture("keyboard-%dx%d"%[size.x,size.y])
	root.size=Vector2i(1280,720)
	await fresh("res://level_1.tscn",1,"finn_player_id");var screens=level.get_node("GameScreens");screens.open_help();await frames(3)
	check("ajuda embutida pausa sem liberar fases",paused and screens.help_open and screens.help_view.key_count==104)
	screens.help_view.close();await frames(12);check("fechar devolve controles sem pausa residual",not paused and not screens.help_open and not level.finn.movement_locked)
	var story=level.get_node("FriendshipStory");check("conversa inferior com retratos dos dois amigos",story.card.position.y>root.get_visible_rect().size.y*0.6 and story.partner_portrait.texture!=null)
	await capture("bottom-conversation")
	var hud=screens.adventure_hud;PROGRESS.collect(3);hud.sync();await frames(8)
	check("HUD preenche cristal conquistado e inicia brilho",3 in hud.acquired and hud.emblem.pulses.has(3))
	PROGRESS.reset();check("nova aventura remove progresso e desbloqueios",PROGRESS.read().crystals.is_empty() and not PROGRESS.unlocked(2))
	await finish("Campanha, teclado e apresentação: testes isolados de interface")
