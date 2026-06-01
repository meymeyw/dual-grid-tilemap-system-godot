extends Node2D

@export var dualGridTilemap : DualGridTilemap

func _process(_delta):
	var coords: Vector2i = dualGridTilemap.localToMap(global_position)

	if Input.is_action_pressed("left_click"):
		dualGridTilemap.setTile(coords, dualGridTilemap.TerrainType.DIRT)
	elif Input.is_action_pressed("middle_click"):
		dualGridTilemap.setTile(coords, DualGridTilemap.TerrainType.GRASS)
	elif Input.is_action_pressed("right_click"):
		dualGridTilemap.setTile(coords, DualGridTilemap.TerrainType.SAND)

func _physics_process(_delta):
	global_position = _get_world_pos_tile(get_global_mouse_position()) + Vector2(8, 8)

static func _get_world_pos_tile(world_pos: Vector2) -> Vector2:
	var x := floori(world_pos.x / DualGridTilemap.TILE_SIZE) * DualGridTilemap.TILE_SIZE
	var y := floori(world_pos.y / DualGridTilemap.TILE_SIZE) * DualGridTilemap.TILE_SIZE
	return Vector2(x, y)
