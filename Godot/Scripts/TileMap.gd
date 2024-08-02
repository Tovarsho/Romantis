extends TileMap

func _use_tile_data_runtime_update(_layer, coords):
	if coords in get_used_cells_by_id(2):
		return true
	return false

func 	_tile_data_runtime_update(_layer, _coords, tile_data):
	tile_data.set_navigation_polygon(0,null)
