extends TileMap

class_name DualGridTilemap

@export var displayTilemap : TileMap
@export var grassPlaceholderAtlasCoord : Vector2i
@export var dirtPlaceholderAtlasCoord : Vector2i

var NEIGHBOURS : Array = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(1, 1)
]

var neighboursToAtlasCoord : Dictionary = {
	"Grass, Grass, Grass, Grass" = Vector2i(2, 1), 		# All corners
	"Dirt, Dirt, Dirt, Grass" = Vector2i(1, 3), 		# Outer bottom-right corner
	"Dirt, Dirt, Grass, Dirt" = Vector2i(0, 0), 		# Outer bottom-left corner
	"Dirt, Grass, Dirt, Dirt" = Vector2i(0, 2), 		# Outer top-right corner
	"Grass, Dirt, Dirt, Dirt" = Vector2i(3, 3), 		# Outer top-left corner
	"Dirt, Grass, Dirt, Grass" = Vector2i(1, 0), 		# Right edge
	"Grass, Dirt, Grass, Dirt" = Vector2i(3, 2), 		# Left edge
	"Dirt, Dirt, Grass, Grass" = Vector2i(3, 0), 		# Bottom edge
	"Grass, Grass, Dirt, Dirt" = Vector2i(1, 2), 		# Top edge
	"Dirt, Grass, Grass, Grass" = Vector2i(1, 1), 		# Inner bottom-right corner
	"Grass, Dirt, Grass, Grass" = Vector2i(2, 0), 		# Inner bottom-left corner
	"Grass, Grass, Dirt, Grass" = Vector2i(2, 2), 		# Inner top-right corner
	"Grass, Grass, Grass, Dirt" = Vector2i(3, 1), 		# Inner top-left corner
	"Dirt, Grass, Grass, Dirt" = Vector2i(2, 3), 		# Bottom-left top-right corners
	"Grass, Dirt, Dirt, Grass" = Vector2i(0, 1), 		# Top-left down-right corners
	"Dirt, Dirt, Dirt, Dirt" = Vector2i(0, 3) 			# No corners
}

func _ready():
	_reloadDisplayTiles()

func _reloadDisplayTiles():
	# Refresh all display tiles
	for coord : Vector2i in get_used_cells(0):
		setDisplayTile(coord)

func SetTile(coords: Vector2i, atlasCoords: Vector2i):
	set_cell(0, coords, 0, atlasCoords);
	setDisplayTile(coords)

func setDisplayTile(pos: Vector2i):
	var i: int = 0
	i += 1
	var newPos: Vector2i = pos + NEIGHBOURS[i]
	displayTilemap.set_cell(0, newPos, 1, calculateDisplayTile(newPos))

func calculateDisplayTile(coords: Vector2i):
	# get 4 world tile neighbours
	var botRight = getWorldTile(coords - NEIGHBOURS[0])
	var botLeft = getWorldTile(coords - NEIGHBOURS[1])
	var topRight = getWorldTile(coords - NEIGHBOURS[2])
	var topLeft = getWorldTile(coords - NEIGHBOURS[3])

	# return tile (atlas coord) that fits the neighbour rules
	return neighboursToAtlasCoord[str(topLeft, ", ", topRight, ", ", botLeft, ", ", botRight)]

func getWorldTile(coords: Vector2i):
	var atlasCoord = get_cell_atlas_coords(0, coords)
	if atlasCoord == grassPlaceholderAtlasCoord:
		return "Grass"
	else:
		return "Dirt"

enum TileType {
	None,
	Grass,
	Dirt
}
