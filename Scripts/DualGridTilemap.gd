extends Node2D

class_name DualGridTilemap

const TILE_SIZE = 16
const HALF_TILE_SIZE = TILE_SIZE / 2

var NEIGHBOURS : Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1)
]

# Key: [topLeft, topRight, botLeft, botRight] as TileType ints
# Value: atlas coord on the display tileset
const neighboursToAtlasCoord : Dictionary = {
	[TileType.SOME, TileType.SOME, TileType.SOME, TileType.SOME]: Vector2i(2, 1),  # All corners
	[TileType.NONE, TileType.NONE, TileType.NONE, TileType.SOME]: Vector2i(1, 3),  # Outer bottom-right corner
	[TileType.NONE, TileType.NONE, TileType.SOME, TileType.NONE]: Vector2i(0, 0),  # Outer bottom-left corner
	[TileType.NONE, TileType.SOME, TileType.NONE, TileType.NONE]: Vector2i(0, 2),  # Outer top-right corner
	[TileType.SOME, TileType.NONE, TileType.NONE, TileType.NONE]: Vector2i(3, 3),  # Outer top-left corner
	[TileType.NONE, TileType.SOME, TileType.NONE, TileType.SOME]: Vector2i(1, 0),  # Right edge
	[TileType.SOME, TileType.NONE, TileType.SOME, TileType.NONE]: Vector2i(3, 2),  # Left edge
	[TileType.NONE, TileType.NONE, TileType.SOME, TileType.SOME]: Vector2i(3, 0),  # Bottom edge
	[TileType.SOME, TileType.SOME, TileType.NONE, TileType.NONE]: Vector2i(1, 2),  # Top edge
	[TileType.NONE, TileType.SOME, TileType.SOME, TileType.SOME]: Vector2i(1, 1),  # Inner bottom-right corner
	[TileType.SOME, TileType.NONE, TileType.SOME, TileType.SOME]: Vector2i(2, 0),  # Inner bottom-left corner
	[TileType.SOME, TileType.SOME, TileType.NONE, TileType.SOME]: Vector2i(2, 2),  # Inner top-right corner
	[TileType.SOME, TileType.SOME, TileType.SOME, TileType.NONE]: Vector2i(3, 1),  # Inner top-left corner
	[TileType.NONE, TileType.SOME, TileType.SOME, TileType.NONE]: Vector2i(2, 3),  # Bottom-left top-right corners
	[TileType.SOME, TileType.NONE, TileType.NONE, TileType.SOME]: Vector2i(0, 1),  # Top-left bottom-right corners
	[TileType.NONE, TileType.NONE, TileType.NONE, TileType.NONE]: Vector2i(-1, -1) # No corners — treated as empty
}

enum TileType { NONE, SOME }
enum TerrainType {
	EMPTY = -1,
	GRASS = 1,
	DIRT = 2,
	SAND = 3
}

@export var worldMapLayer : TileMapLayer
@export var dirtDisplayMapLayer : TileMapLayer
@export var sandDisplayMapLayer : TileMapLayer
@export var grassDisplayMapLayer : TileMapLayer
@export var dirtPlaceholderAtlasCoords : Vector2i
@export var sandPlaceholderAtlasCoords : Vector2i
@export var grassPlaceholderAtlasCoords : Vector2i

var placeholderSourceId : int = 0

func _ready() -> void:
	_refreshAllTiles()

func _refreshAllTiles() -> void:
	for cell_pos : Vector2i in worldMapLayer.get_used_cells():
		_refreshDisplayTile(cell_pos, grassDisplayMapLayer, TerrainType.GRASS)
		_refreshDisplayTile(cell_pos, dirtDisplayMapLayer, TerrainType.DIRT)
		_refreshDisplayTile(cell_pos, sandDisplayMapLayer, TerrainType.SAND)

func localToMap(pos: Vector2) -> Vector2i:
	return worldMapLayer.local_to_map(pos)

func setTile(coords: Vector2i, terrain_type: TerrainType) -> void:
	var oldTerrainType : TerrainType = getTerrainType(coords)

	worldMapLayer.set_cell(coords, placeholderSourceId, getPlaceholderAtlasCoords(terrain_type))
	_refreshDisplayTile(coords, getDisplayLayer(terrain_type), terrain_type)
	
	# Refresh old display layer if the terrain type has changed
	if oldTerrainType != terrain_type && oldTerrainType != TerrainType.EMPTY:
		_refreshDisplayTile(coords, getDisplayLayer(oldTerrainType), oldTerrainType)

func _refreshDisplayTile(pos: Vector2i, display_layer: TileMapLayer, terrain_type: TerrainType) -> void:
	for i in range(NEIGHBOURS.size()):
		var newPos : Vector2i = pos + NEIGHBOURS[i]
		var atlasCoords : Vector2i = _calculateDisplayTileAtlasCoords(newPos, terrain_type)
		if atlasCoords == -Vector2i.ONE:
			display_layer.erase_cell(newPos)
		else:
			display_layer.set_cell(newPos, terrain_type, atlasCoords)

func _calculateDisplayTileAtlasCoords(coords: Vector2i, terrain_type: TerrainType) -> Vector2i:
	var bot_right : TileType = _getMatchingTileType(coords - NEIGHBOURS[0], terrain_type)
	var bot_left  : TileType = _getMatchingTileType(coords - NEIGHBOURS[1], terrain_type)
	var top_right : TileType = _getMatchingTileType(coords - NEIGHBOURS[2], terrain_type)
	var top_left  : TileType = _getMatchingTileType(coords - NEIGHBOURS[3], terrain_type)

	return neighboursToAtlasCoord[[top_left, top_right, bot_left, bot_right]]

func _getMatchingTileType(coords: Vector2i, terrain_type: TerrainType) -> TileType:
	var targetCoords: Vector2i = getPlaceholderAtlasCoords(terrain_type)
	var atlasCoord: Vector2i = worldMapLayer.get_cell_atlas_coords(coords)
	if atlasCoord != targetCoords:
		return TileType.NONE
	return TileType.SOME

func getPlaceholderAtlasCoords(terrain_type: TerrainType) -> Vector2i:
	match terrain_type:
		TerrainType.GRASS	: return grassPlaceholderAtlasCoords
		TerrainType.DIRT	: return  dirtPlaceholderAtlasCoords
		TerrainType.SAND	: return  sandPlaceholderAtlasCoords
		_					: return -Vector2i.ONE

func getDisplayLayer(terrain_type: TerrainType) -> TileMapLayer:
	match terrain_type:
		TerrainType.GRASS : return grassDisplayMapLayer
		TerrainType.DIRT  : return  dirtDisplayMapLayer
		TerrainType.SAND  : return  sandDisplayMapLayer
		_: return null

func getTerrainType(cell_pos: Vector2i) -> TerrainType:
	var coords : Vector2i = worldMapLayer.get_cell_atlas_coords(cell_pos)
	if   coords == grassPlaceholderAtlasCoords	: return TerrainType.GRASS
	elif coords ==  dirtPlaceholderAtlasCoords	: return TerrainType.DIRT
	elif coords ==  sandPlaceholderAtlasCoords	: return TerrainType.SAND
	elif coords == -Vector2i.ONE				: return TerrainType.EMPTY
	else:
		push_error("Unknown placeholder atlas coords: %s. Defaulting to Grass." % coords)
		return TerrainType.GRASS
