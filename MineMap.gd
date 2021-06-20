extends Node

var _mine_count := 0

# A 2D array of int, -1: mine, other: mine count around it
var _tiles := []

func is_empty() -> bool:
	return _tiles.empty()

func get_size_x() -> int: 
	return _tiles.size()

func get_size_y() -> int:
	var x_tiles = _tiles.front() as Array
	return (
		x_tiles.size()
		if x_tiles
		else 0
		)

func get_mine_count() -> int:
	 return _mine_count

func get_size() -> int:
	 return get_size_x() * get_size_y()

# returns -2: out of bounds, -1: mine, other: mine count around it
func get_tile(x: int, y: int) -> int:
	if x > get_size_x() - 1 or y > get_size_y() - 1: return -2
	return _tiles[x][y]

# x and y will be 0 if it's negative, mine_count is clampped within 0 to (x * y)
func generate(x: int, y: int, mine_count: int):
	_mine_count = clamp(mine_count, 0, x * y)
	if x * y == 0:
		_tiles = []
		return
	
	# populate tiles with 0s
	_tiles = []
	for index_x in range(x):
		var row_x_tiles = []
		for index_y in range(y):
			row_x_tiles.append(0)
		_tiles.append(row_x_tiles)
	
	if mine_count < 0: return
	
	# pick mine_indices
	var indices = range(x * y)
	indices.shuffle()
	var flat_mine_indices = indices.slice(0, mine_count - 1)
	
	# insert mines and increment neighbors
	for flat_mine_index in flat_mine_indices:
		var mine_index_x = int(floor(flat_mine_index / y))
		var mine_index_y = flat_mine_index % y
		_tiles[mine_index_x][mine_index_y] = -1
		var neighbor_indices = _get_neighbor_indices(mine_index_x, mine_index_y)
		for neighbor_index in neighbor_indices:
			if _tiles[neighbor_index.x][neighbor_index.y] == -1: continue
			_tiles[neighbor_index.x][neighbor_index.y] += 1

# returns [] if index is out of bounds
func _get_neighbor_indices(x: int, y: int) -> Array:
	if x > get_size_x() - 1 or y > get_size_y() - 1: return []
	
	var neighbor_indices = []
	
	var negativeOneToOne = range(-1, 2, 1)
	for delta_x in negativeOneToOne:
		for delta_y in negativeOneToOne:
			if delta_x == 0 and delta_y == 0: continue
			var neighbor_x = x + delta_x
			var neighbor_y = y + delta_y
			if (neighbor_x < 0 or
				neighbor_x > get_size_x() - 1 or
				neighbor_y < 0 or
				neighbor_y > get_size_y() -1): continue
			neighbor_indices.append(Vector2(neighbor_x, neighbor_y))
	
	return neighbor_indices

func _to_string() -> String:
	var to_print = ""
	for y in range(get_size_y()):
		for x in range(get_size_x()):
			if x != 0: to_print += " "
			var tile = (
				str(_tiles[x][y])
				if _tiles[x][y] != -1
				else "*"
			)
			to_print += tile
			if x == get_size_x() - 1: to_print += "\n"
	return to_print
