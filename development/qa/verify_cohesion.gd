extends "res://tests/journey_driver.gd"
## Inspeções de apresentação são estados isolados, separados das rotas cooperativas.
const KEYS={1:"finn_player_id",2:"cake_player_id",3:"lead_player_id",4:"lead_player_id",5:"lead_player_id",6:"primary_player_id"}
func run() -> void:
	root.size=viewport_size
	for phase in range(1,7):
		await fresh("res://level_%d.tscn"%phase,1,KEYS[phase]);await frames(35)
		check("F%d usa a referência local comum"%phase,root.content_scale_size==Vector2i(1152,648))
		var art: Array=level.find_children("PlateArtwork","Sprite2D",true,false)
		if phase!=5:check("F%d tem placas em atlas com quatro estados"%phase,not art.is_empty() and art.all(func(n):return n.hframes==4 and "cohesion_18_11" in n.texture.resource_path))
		var world=level.get_node_or_null("WorldAtmosphere")
		check("F%d possui atmosfera em sprites, sem colisão"%phase,world!=null and world.lights.size()==10)
		await capture("phase%d-start"%phase)
		if phase in [1,2,6]:
			var x: float=world.clouds[0].position.x;await frames(65)
			check("F%d nuvens se movem discretamente"%phase,world.clouds[0].position.x!=x)
		if phase==3:
			var station=level.get_node("RegionalLayout/MusicalStationArtwork")
			check("ressonador está inteiro sobre a margem",station.battery.global_position.x-28>=1600)
			check("receptor usa o recorte sem fragmentos",station.receiver.texture is AtlasTexture and station.receiver.texture.region.size.y==48)
		if phase==1:
			var skin=level.final_gate.get_node_or_null("LocalFinish")
			check("portão final também usa o acabamento da trilha",skin!=null)
			if viewport_size.x<=1280:
				record_dir=capture_dir.path_join("ambient-frames");record_interval=6;DirAccess.make_dir_recursive_absolute(record_dir)
				await frames(180);record_dir=""
	await finish("Coesão: enquadramento, sprites e suportes visuais")
