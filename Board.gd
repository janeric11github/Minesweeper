extends TileMap

enum Tile { BLANK = 12, FLAG, MINE, N0, N1, N2, N3, N4, N5, N6, N7, N8 }

var _map := HiddenMineMap.new()

func show_map(map: HiddenMineMap):
	_map = map
	_map.connect("tiles_revealed", self, "_on_HiddenMineMap_tiles_revealed")
	_map.connect("tile_flagged", self, "_on_HiddenMineMap_tile_flagged")
	_map.connect("tile_unflagged", self, "_on_HiddenMineMap_tile_unflagged")
	
	for x in range(map.get_size_x()):
		for y in range(map.get_size_y()):
			var map_tile = map.get_tile(x, y)
			var board_tile = _get_board_tile(map_tile)
			set_cell(x, y, board_tile)

func _on_HiddenMineMap_tiles_revealed(index_to_tiles: Dictionary):
	for key in index_to_tiles.keys():
		var map_tile = index_to_tiles[key]
		var board_tile = _get_board_tile(map_tile)
		var index = key as Vector2
		set_cell(index.x, index.y, board_tile)

func _on_HiddenMineMap_tile_flagged(x: int, y: int, map_tile: int):
	var board_tile = _get_board_tile(map_tile)
	set_cell(x, y, board_tile)
	
func _on_HiddenMineMap_tile_unflagged(x: int, y: int, map_tile: int):
	var board_tile = _get_board_tile(map_tile)
	set_cell(x, y, board_tile)

func _get_board_tile(map_tile: int) -> int:
	match map_tile:
		HiddenMineMap.Tile.UNKNOWN: return Tile.BLANK
		HiddenMineMap.Tile.BLANK: return Tile.BLANK
		HiddenMineMap.Tile.FLAGGED: return Tile.FLAG
		HiddenMineMap.Tile.MINE: return Tile.MINE
		HiddenMineMap.Tile.N0: return Tile.N0
		HiddenMineMap.Tile.N1: return Tile.N1
		HiddenMineMap.Tile.N2: return Tile.N2
		HiddenMineMap.Tile.N3: return Tile.N3
		HiddenMineMap.Tile.N4: return Tile.N4
		HiddenMineMap.Tile.N5: return Tile.N5
		HiddenMineMap.Tile.N6: return Tile.N6
		HiddenMineMap.Tile.N7: return Tile.N7
		HiddenMineMap.Tile.N8: return Tile.N8
		_: return Tile.BLANK

func _input(event):
	if event.is_action_pressed("left_click"):
		var local_mouse_position = get_local_mouse_position()
		var cell_index = _get_cell_index(local_mouse_position)
		var tile = _map.get_tile(cell_index.x, cell_index.y)
		match tile:
			HiddenMineMap.Tile.BLANK:
				_map.reveal(cell_index.x, cell_index.y)
			HiddenMineMap.Tile.N0,\
			HiddenMineMap.Tile.N1,\
			HiddenMineMap.Tile.N2,\
			HiddenMineMap.Tile.N3,\
			HiddenMineMap.Tile.N4,\
			HiddenMineMap.Tile.N5,\
			HiddenMineMap.Tile.N6,\
			HiddenMineMap.Tile.N7:
				_map.chord(cell_index.x, cell_index.y)
	elif event.is_action_pressed("right_click"):
		var local_mouse_position = get_local_mouse_position()
		var cell_index = _get_cell_index(local_mouse_position)
		_map.toggle_flag(cell_index.x, cell_index.y)

func _get_cell_index(local_position: Vector2) -> Vector2:
	var cell_size_x_pixel = cell_size.x * scale.x
	var cell_size_y_pixel = cell_size.y * scale.y
	var cell_x = floor(local_position.x / cell_size_x_pixel)
	var cell_y = floor(local_position.y / cell_size_y_pixel)
	return Vector2(cell_x, cell_y)

func _get_used_rect_pixel() -> Rect2:
	var used_rect = get_used_rect()
	var cell_to_pixel = Transform2D(Vector2(cell_size.x * scale.x, 0), Vector2(0, cell_size.y * scale.y), Vector2())
	return Rect2(cell_to_pixel * used_rect.position, cell_to_pixel * used_rect.size)
