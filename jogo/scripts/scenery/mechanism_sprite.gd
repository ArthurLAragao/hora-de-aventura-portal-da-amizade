extends RefCounted
## Atlas locais já preparados; não gera imagens nem muda detecção de mecanismos.
const ROOT="res://Assets/03_Objects_and_Puzzles/cohesion_18_11/"
static func phase(node: Node) -> int:
	var current:=node
	while current!=null:
		for number in range(1,7):
			if current.scene_file_path.ends_with("level_%d.tscn"%number):return number
		current=current.get_parent()
	return 1
static func plate(parent: Node,region: int,reunion:=false) -> Sprite2D:
	var themes={1:"forest",2:"ice",3:"cave",4:"workshop",5:"sanctuary",6:"sanctuary"}
	var skin:=Sprite2D.new();skin.name="PlateArtwork";skin.texture=load(ROOT+"plate_"+("reunion" if reunion else themes[region])+".png")
	skin.hframes=4;skin.position=Vector2(0,-11);skin.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;skin.z_index=2;parent.add_child(skin);return skin
static func state(active: bool,complete: bool,available:=true) -> int:
	return 3 if complete else 2 if active else 1 if available else 0
