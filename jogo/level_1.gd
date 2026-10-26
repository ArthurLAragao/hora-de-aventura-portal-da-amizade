@tool
extends Node2D

@onready var terrain: TileMap = $TileMap
@onready var scenery: Node2D = $Scenery

const DECORATION_PATHS: Array[String] = [
	"res://Assets/02_Environments/01_tree_house/tiles/decor_01.png",
	"res://Assets/02_Environments/01_tree_house/tiles/decor_02.png",
	"res://Assets/02_Environments/01_tree_house/tiles/decor_03.png",
	"res://Assets/02_Environments/01_tree_house/tiles/decor_04.png",
]

const DECORATION_POSITIONS: Array[Vector2] = [
	Vector2(48,264), Vector2(104,264), Vector2(164,264), Vector2(332,264),
	Vector2(714,264), Vector2(864,264), Vector2(1296,264), Vector2(1350,264),
	Vector2(1790,264), Vector2(1830,264), Vector2(2044,264), Vector2(2150,264),
	Vector2(136,264), Vector2(200,264), Vector2(1318,264), Vector2(1854,264),
]

const MISALIGNED_TERRAIN_CELLS: Array[Vector2i] = [
	Vector2i(11, 12), Vector2i(13, 11), Vector2i(15, 10),
	Vector2i(17, 12), Vector2i(14, 13), Vector2i(18, 13),
]

func _ready() -> void:
	_remove_misaligned_terrain_tiles()
	_extend_start_platform()
	_widen_jake_bridge_gap()
	_extend_existing_ground()
	_add_existing_grass_decoration()
	_add_wayfinding()

func _remove_misaligned_terrain_tiles() -> void:
	# Remove the six orphaned decorative/platform cells that floated above or inside the first gap.
	for cell in MISALIGNED_TERRAIN_CELLS:
		terrain.erase_cell(0, cell)

func _extend_start_platform() -> void:
	# The original start pad began only one tile before Finn; extend it to the left world boundary.
	for column in range(0, 8):
		for row in range(14, 20):
			var source_cell := Vector2i(7 if column == 0 else 8, row)
			var source_id := terrain.get_cell_source_id(0, source_cell)
			if source_id < 0:
				continue
			terrain.set_cell(
				0,
				Vector2i(column, row),
				source_id,
				terrain.get_cell_atlas_coords(0, source_cell),
				terrain.get_cell_alternative_tile(0, source_cell)
			)

func _widen_jake_bridge_gap() -> void:
	# Keep the Jake bridge puzzle as the intended route across the opening.
	for row in range(14, 20):
		terrain.erase_cell(0, Vector2i(14, row))
		terrain.erase_cell(0, Vector2i(18, row))

func _extend_existing_ground() -> void:
	# Reuse the current terrain tiles all the way to the end of the phase.
	for column in range(25, 68):
		for row in range(14, 20):
			var source_cell := Vector2i(22, row)
			var source_id := terrain.get_cell_source_id(0, source_cell)
			if source_id < 0:
				continue
			terrain.set_cell(
				0,
				Vector2i(column, row),
				source_id,
				terrain.get_cell_atlas_coords(0, source_cell),
				terrain.get_cell_alternative_tile(0, source_cell)
			)

func _add_existing_grass_decoration() -> void:
	# Supplied Tree House plants, without collision, away from puzzle hotspots.
	if scenery.has_node("GeneratedGrass"):
		return
	var grass_group := Node2D.new()
	grass_group.name = "GeneratedGrass"
	grass_group.z_index = -1
	scenery.add_child(grass_group)
	for index in DECORATION_POSITIONS.size():
		var grass := Sprite2D.new()
		grass.name = "Grass_%02d" % index
		grass.texture = load(DECORATION_PATHS[index % DECORATION_PATHS.size()]) as Texture2D
		grass.position = DECORATION_POSITIONS[index]
		grass.z_index = 0
		grass.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		grass_group.add_child(grass)

func _add_wayfinding() -> void:
	# @tool executes in both editor/runtime. One generated group, no saved duplicates.
	if scenery.has_node("RouteLabels"): return
	var group:=Node2D.new()
	group.name="RouteLabels"
	scenery.add_child(group)
	var captions: Array[String]=["1  PONTE EM DUPLA", "2  TRONCO NA PLACA", "3  DUAS PLACAS", "CRISTAL E SAÍDA"]
	var positions: Array[Vector2]=[Vector2(346,176),Vector2(934,176),Vector2(1400,176),Vector2(1940,164)]
	for index in captions.size():
		var label:=Label.new()
		label.text=captions[index]
		label.position=positions[index]
		label.add_theme_font_size_override("font_size",13)
		label.add_theme_color_override("font_color",Color("fff2c7"))
		label.add_theme_color_override("font_outline_color",Color("102431"))
		label.add_theme_constant_override("outline_size",5)
		group.add_child(label)
