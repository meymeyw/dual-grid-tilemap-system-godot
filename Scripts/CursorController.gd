extends Node2D

@export var dualGridTilemap : DualGridTilemap

func _process(_delta):
	var update = false
	var coords: Vector2i = dualGridTilemap.local_to_map(global_position)

	if Input.is_action_pressed("left_click"):
		dualGridTilemap.set_cell(0, coords, 0, dualGridTilemap.dirtPlaceholderAtlasCoord)
		update = true

	elif Input.is_action_pressed("right_click"):
		dualGridTilemap.set_cell(0, coords, 0, dualGridTilemap.grassPlaceholderAtlasCoord)
		update = true

	if update == true:
		dualGridTilemap._reloadDisplayTiles()


func _physics_process(_delta):
	global_position = get_global_mouse_position()
