extends Node

class_name HiddenMineMap

signal tiles_revealed(index_to_tiles)

signal tile_flagged(x, y, tile)
signal tile_unflagged(x, y, tile)

enum Tile { UNKNOWN, BLANK, FLAGGED, MINE, N0, N1, N2, N3, N4, N5, N6, N7, N8 }

enum InnerTile { BLANK, FLAGGED, REVEALED }
# A 2D array of int, -1: mine, other: mine count around it
#var _tiles := []

var MineMap = preload("res://MineMap.gd")

var _mine_map = MineMap.new()

# A 2D array of InnerCell
var _inner_tiles = []

func is_empty() -> bool:
	return _mine_map.is_empty()

func get_size_x() -> int: 
	return _mine_map.get_size_x()

func get_size_y() -> int:
	return _mine_map.get_size_y()

func get_mine_count() -> int:
	 return _mine_map.get_mine_count()

func get_size() -> int:
	return _mine_map.get_size()

# returns Tile
func get_tile(x: int, y: int) -> int:
	if x > get_size_x() - 1 or y > get_size_y() - 1: return Tile.UNKNOWN
	var inner_tile = _inner_tiles[x][y]
	match inner_tile:
		InnerTile.BLANK: return Tile.BLANK
		InnerTile.FLAGGED: return Tile.FLAGGED
		InnerTile.REVEALED: 
			match _mine_map.get_tile(x, y):
				-1: return Tile.MINE
				0: return Tile.N0
				1: return Tile.N1
				2: return Tile.N2
				3: return Tile.N3
				4: return Tile.N4
				5: return Tile.N5
				6: return Tile.N6
				7: return Tile.N7
				8: return Tile.N8
	return Tile.UNKNOWN	

# x and y will be 0 if it's negative, mine_count is clampped within 0 to (x * y)
func generate(x: int, y: int, mine_count: int):
	_mine_map.generate(x, y, mine_count)
	_inner_tiles = []
	
	if x * y == 0: return
	
	# populate _inner_tiles with InnerTile.BLANK
	for index_x in range(x):
		var row_x_cells = []
		for index_y in range(y):
			row_x_cells.append(InnerTile.BLANK)
		_inner_tiles.append(row_x_cells)
	
	print(self)

# returns [] if index is out of bounds
func _get_neighbor_indices(x: int, y: int) -> Array:
	return _mine_map._get_neighbor_indices(x, y)

func reveal(x, y):
	var index_to_tiles = {}
	_reveal(x, y, index_to_tiles)
	emit_signal("tiles_revealed", index_to_tiles)
	
	print(self)

func _reveal(x: int, y: int, index_to_tiles: Dictionary):
	var tile = get_tile(x, y)
	if tile != Tile.BLANK: return
	
	if index_to_tiles.has(Vector2(x, y)): return
	
	_inner_tiles[x][y] = InnerTile.REVEALED
	
	var new_tile = get_tile(x, y)
	
	index_to_tiles[Vector2(x, y)] = new_tile
	
	if new_tile == Tile.N0:
		for neighbor_index in _get_neighbor_indices(x, y):
			_reveal(neighbor_index.x, neighbor_index.y, index_to_tiles)

func toggle_flag(x, y):
	var tile = get_tile(x, y)
	match tile:
		Tile.BLANK:
			_inner_tiles[x][y] = InnerTile.FLAGGED
			var new_tile = get_tile(x, y)
			emit_signal("tile_flagged", x, y, new_tile)
		Tile.FLAGGED:
			_inner_tiles[x][y] = InnerTile.BLANK
			var new_tile = get_tile(x, y)
			emit_signal("tile_unflagged", x, y, new_tile)
	
	print(self)

func chord(x, y):
	var tile = get_tile(x, y)
	var required_flag_count: int
	match tile:
		Tile.N1: required_flag_count = 1
		Tile.N2: required_flag_count = 2
		Tile.N3: required_flag_count = 3
		Tile.N4: required_flag_count = 4
		Tile.N5: required_flag_count = 5
		Tile.N6: required_flag_count = 6
		Tile.N7: required_flag_count = 7
		_: return
	
	var flag_count = 0
	var neighbor_indices = _get_neighbor_indices(x, y)
	for neighbor_index in neighbor_indices:
		var neighbor_tile = get_tile(neighbor_index.x, neighbor_index.y)
		if neighbor_tile != Tile.FLAGGED: continue
		flag_count += 1
	
	if flag_count < required_flag_count: return
	
	var index_to_tiles = {}
	for neighbor_index in neighbor_indices:
		_reveal(neighbor_index.x, neighbor_index.y, index_to_tiles)
	emit_signal("tiles_revealed", index_to_tiles)
	
	print(self)

func _to_string() -> String:
	var to_print = ""
	for y in range(get_size_y()):
		for x in range(get_size_x()):
			if x != 0: to_print += " "
			var inner_tile = _inner_tiles[x][y]
			var mine_map_tile = _mine_map.get_tile(x, y)
			var tile_to_print = ""
			var format = ""
			match inner_tile:
				InnerTile.BLANK: format = "[%s]"
				InnerTile.FLAGGED: format = "<%s>"
				InnerTile.REVEALED: format = " %s "
			match mine_map_tile:
				-1: tile_to_print = format % ["*"]
				_: tile_to_print = format % [str(mine_map_tile)]
			to_print += tile_to_print
			if x == get_size_x() - 1: to_print += "\n"
	return to_print

