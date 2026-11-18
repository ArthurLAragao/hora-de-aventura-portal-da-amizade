extends "res://tests/journey_driver.gd"
## Estados de apresentação preparados isoladamente; não contam como percurso.
const PROGRESS=preload("res://scripts/core/campaign_progress.gd")
func event(code: Key,pressed: bool) -> void:
	var input:=InputEventKey.new();input.keycode=code;input.physical_keycode=code;input.pressed=pressed;Input.parse_input_event(input);await frames(3)
func run() -> void:
	root.size=Vector2i(1280,720)
	await fresh("res://level_1.tscn",1,"finn_player_id")
	var screens=level.get_node("GameScreens");screens.open_help();await frames(4)
	await event(KEY_ESCAPE,true);await event(KEY_ESCAPE,false);await frames(10)
	check("Esc fecha ajuda e mantém a fase ativa",current_scene==level and not screens.help_open and not paused)
	for count in range(1,7):
		PROGRESS.collect(count);screens.adventure_hud.sync();await frames(4)
	check("seis encaixes preenchidos sem duplicação",screens.adventure_hud.acquired.size()==6)
	await capture("six-crystal-hud")
	await event(KEY_F1,true);await event(KEY_F1,false);await frames(4)
	record_dir=capture_dir.path_join("keyboard-frames");record_interval=6;DirAccess.make_dir_recursive_absolute(record_dir)
	await event(KEY_D,true);await frames(18);await event(KEY_D,false);await event(KEY_W,true);await frames(20);await event(KEY_W,false)
	await event(KEY_ENTER,true);await frames(16);await event(KEY_ENTER,false);await frames(14);record_dir=""
	screens.close_help();await frames(12)
	PROGRESS.write({"version":1,"completed":[1,2,3,4,5,6],"crystals":[1,2,3,4,5,6],"restored":false})
	await fresh("res://monument_finale.tscn",1,"primary_player_id")
	check("monumentos começam vazios",level.placed.is_empty() and not level.finished)
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(8)
		check("epílogo enquadrado em %s"%size,Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(level.design.get_global_rect()))
		var panorama: Sprite2D=level.get_node("Background/Panorama")
		var extent:=Rect2(-panorama.texture.get_size()*0.5,panorama.texture.get_size())
		var bounds:=panorama.get_global_transform_with_canvas()*extent
		check("fundo cobre o epílogo em %s"%size,bounds.grow(2).encloses(Rect2(Vector2.ZERO,root.get_visible_rect().size)))
		await capture("monuments-empty-%dx%d"%[size.x,size.y])
	root.size=Vector2i(1280,720)
	for i in 5:level.place(i)
	check("cinco depósitos não encerram a aventura",not level.finished and not level.celebration_started and not PROGRESS.read().restored)
	check("depósito repetido não duplica cristal",not level.place(0) and level.placed.size()==5)
	record_dir=capture_dir.path_join("victory-frames");record_interval=6;DirAccess.make_dir_recursive_absolute(record_dir)
	level.place(5);await frames(360);record_dir=""
	check("restauração salva apenas após sexto depósito",level.finished and PROGRESS.read().restored and level.has_node("Celebration"))
	var ending=level.get_node("Celebration")
	for size in [Vector2i(800,450),Vector2i(1024,768),Vector2i(1280,720),Vector2i(1920,1080)]:
		root.size=size;await frames(8)
		var button: Button=ending.get_node("Menu");var transform:=button.get_global_transform_with_canvas()
		var bounds:=Rect2(transform*Vector2.ZERO,button.size*ending.scale)
		check("vitória e retorno acessíveis em %s"%size,Rect2(Vector2.ZERO,root.get_visible_rect().size).grow(1).encloses(bounds) and not button.disabled)
		await capture("victory-%dx%d"%[size.x,size.y])
	ending.get_node("Menu").pressed.emit();await frames(30);level=current_scene
	check("retorno final abre menu sem pausa residual",level.scene_file_path=="res://Assets/04_Interface/Godot/main_menu.tscn" and not paused)
	await finish("Apresentação: teclas, relicário, monumentos e vitória responsiva")
