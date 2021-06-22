class_name HiddenMineMap
extends Node

signal tiles_revealed(index_to_tiles)

signal tiles_flagged(index_to_tiles)
signal tiles_unflagged(index_to_tiles)

signal tiles_pressed(index_to_tiles)
signal tiles_released(index_to_tiles)

signal won

enum Tile { UNKNOWN, BLANK, FLAGGED, MINE, N0, N1, N2, N3, N4, N5, N6, N7, N8 }

enum InnerTile { BLANK, FLAGGED, PRESSED, REVEALED }
# A 2D array of int, -1: mine, other: mine count around it
#var _tiles := []

var MineMap = preload("res://MineMap.gd")

var _mine_map = MineMap.new()

# A 2D array of InnerTile
var _inner_tiles := []

var _revealed_non_mine_tile_count := 0
var _unrevealed_tile_index_to_flagged := {}

var _pressed_tile_indices := []
var _pressed_index := Vector2(-1, -1) 

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
	if not is_index_valid(x, y): return Tile.UNKNOWN
	var inner_tile = _inner_tiles[x][y]
	match inner_tile:
		InnerTile.BLANK: return Tile.BLANK
		InnerTile.FLAGGED: return Tile.FLAGGED
		InnerTile.PRESSED: return Tile.N0
		InnerTile.REVEALED: 
			match _mine_map.get_tile(x, y):
				-2: return Tile.UNKNOWN
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
	_revealed_non_mine_tile_count = 0
	_pressed_tile_indices = []
	_pressed_index = Vector2(-1, -1)
	
	if x * y == 0: return
	
	# populate _inner_tiles with InnerTile.BLANK
	for index_x in range(x):
		var row_x_cells = []
		for index_y in range(y):
			row_x_cells.append(InnerTile.BLANK)
			_unrevealed_tile_index_to_flagged[Vector2(index_x, index_y)] = false
		_inner_tiles.append(row_x_cells)

# returns [] if index is out of bounds
func get_neighbor_indices(x: int, y: int) -> Array:
	return _mine_map.get_neighbor_indices(x, y)

func is_index_valid(x: int, y: int) -> bool:
	return _mine_map.is_index_valid(x, y)

func reveal_or_chord(x, y):
	if not is_index_valid(x, y): return
	var inner_tile = _inner_tiles[x][y]
	match inner_tile:
		InnerTile.BLANK: reveal(x, y)
		InnerTile.REVEALED: chord(x, y)

func reveal(x, y):
	var index_to_tiles = {}
	_reveal(x, y, index_to_tiles)
	emit_signal("tiles_revealed", index_to_tiles)
	_check_won()

func _reveal(x: int, y: int, index_to_tiles: Dictionary):
	if not is_index_valid(x, y): return
	var inner_tile = _inner_tiles[x][y]
	if inner_tile != InnerTile.BLANK: return
	
	if index_to_tiles.has(Vector2(x, y)): return
	
	_inner_tiles[x][y] = InnerTile.REVEALED
	
	var mine_map_tile = _mine_map.get_tile(x, y)
	if mine_map_tile != -1:
		 _revealed_non_mine_tile_count += 1
	_unrevealed_tile_index_to_flagged.erase(Vector2(x, y))
	
	index_to_tiles[Vector2(x, y)] = get_tile(x, y)
	
	if mine_map_tile == 0:
		for neighbor_index in get_neighbor_indices(x, y):
			_reveal(neighbor_index.x, neighbor_index.y, index_to_tiles)

func _check_won():
	var total_non_mine_tile_count = get_size() - get_mine_count()
	if _revealed_non_mine_tile_count < total_non_mine_tile_count : return
	emit_signal("won")

func toggle_flag(x, y):
	_toggle_flag([Vector2(x, y)])

func _toggle_flag(indices: Array):
	var newly_flagged_index_to_tiles = {}
	var newly_unflagged_index_to_tiles = {}
	
	for index in indices:
		if not is_index_valid(index.x, index.y): continue
		var inner_tile = _inner_tiles[index.x][index.y]
		match inner_tile:
			InnerTile.BLANK:
				_inner_tiles[index.x][index.y] = InnerTile.FLAGGED
				newly_flagged_index_to_tiles[Vector2(index.x, index.y)] = get_tile(index.x, index.y)
			InnerTile.FLAGGED:
				_inner_tiles[index.x][index.y] = InnerTile.BLANK
				newly_unflagged_index_to_tiles[Vector2(index.x, index.y)] = get_tile(index.x, index.y)
	
	if not newly_flagged_index_to_tiles.empty():
		emit_signal("tiles_flagged", newly_flagged_index_to_tiles)
	
	if not newly_unflagged_index_to_tiles.empty():
		emit_signal("tiles_unflagged", newly_unflagged_index_to_tiles)

func chord(x, y):
	if not is_index_valid(x, y): return
	var inner_tile = _inner_tiles[x][y]
	var required_flagged_or_revealed_mine_count: int
	match inner_tile:
		InnerTile.REVEALED:
			var mine_map_tile = _mine_map.get_tile(x, y)
			if mine_map_tile < 1 or mine_map_tile > 7: return
			required_flagged_or_revealed_mine_count = mine_map_tile
		_: return
	
	var false_flagged_indices = []
	var flagged_count = 0
	var revealed_mine_count = 0
	var neighbor_indices = get_neighbor_indices(x, y)
	for neighbor_index in neighbor_indices:
		var neighbor_inner_tile = _inner_tiles[neighbor_index.x][neighbor_index.y]
		var neighbor_mine_map_tile = _mine_map.get_tile(neighbor_index.x, neighbor_index.y)
		match neighbor_inner_tile:
			InnerTile.FLAGGED: 
				flagged_count += 1
				if neighbor_mine_map_tile != -1:
					false_flagged_indices.append(Vector2(neighbor_index.x, neighbor_index.y))
			InnerTile.REVEALED:
				if neighbor_mine_map_tile == -1:
					revealed_mine_count += 1
	
	var should_chord = (
		(flagged_count + revealed_mine_count) == required_flagged_or_revealed_mine_count or
		revealed_mine_count == required_flagged_or_revealed_mine_count
		) 
	if not should_chord: return
	
	# unflag false flagged neighbors for revealing later
	_toggle_flag(false_flagged_indices)
	
	var index_to_tiles = {}
	for neighbor_index in neighbor_indices:
		_reveal(neighbor_index.x, neighbor_index.y, index_to_tiles)
	emit_signal("tiles_revealed", index_to_tiles)
	_check_won()

func flag_all_unrevealed_unflagged():
	var unrevealed_unflagged_indices = []
	for unrevealed_tile_index in _unrevealed_tile_index_to_flagged.keys():
		if not is_index_valid(unrevealed_tile_index.x, unrevealed_tile_index.y): continue
		var inner_tile = _inner_tiles[unrevealed_tile_index.x][unrevealed_tile_index.y]
		if inner_tile != InnerTile.BLANK: continue
		unrevealed_unflagged_indices.append(Vector2(unrevealed_tile_index.x, unrevealed_tile_index.y))
	_toggle_flag(unrevealed_unflagged_indices)

func press(x, y):
	_set_pressed_index(Vector2(x, y))

func release():
	_set_pressed_index(Vector2(-1, -1))

func _set_pressed_index(new_pressed_index: Vector2):
	if _pressed_index == new_pressed_index: return
	_pressed_index = new_pressed_index
	_update_pressed_tile_indices()

func _update_pressed_tile_indices():
	if not is_index_valid(_pressed_index.x, _pressed_index.y):
		_set_pressed_tile_indices([])
		return
	var pressed_inner_tile = _inner_tiles[_pressed_index.x][_pressed_index.y]
	match pressed_inner_tile:
		# treat InnerTile.PRESSED as InnerTile.BLANK for moving between two InnerTile.PRESSED tiles
		InnerTile.BLANK,\
		InnerTile.PRESSED: _set_pressed_tile_indices([_pressed_index])
		InnerTile.FLAGGED: _set_pressed_tile_indices([])
		InnerTile.REVEALED:
			var mine_map_tile = _mine_map.get_tile(_pressed_index.x, _pressed_index.y)
			if mine_map_tile == -1: 
				_set_pressed_tile_indices([])
				return
			var new_pressed_tile_indices = []
			for neighbor_index in get_neighbor_indices(_pressed_index.x, _pressed_index.y):
				var neighbor_inner_tile = _inner_tiles[neighbor_index.x][neighbor_index.y]
				match neighbor_inner_tile:
					# treat InnerTile.PRESSED as InnerTile.BLANK for moving between two InnerTile.PRESSED tiles
					InnerTile.BLANK,\
					InnerTile.PRESSED: new_pressed_tile_indices.append(neighbor_index)
			_set_pressed_tile_indices(new_pressed_tile_indices)

func _set_pressed_tile_indices(new_pressed_tile_indices: Array):
	var interseced_indices = []
	
	# release non-intersected old indices
	var released_index_to_tiles = {}
	for pressed_tile_index in _pressed_tile_indices:
		if new_pressed_tile_indices.has(pressed_tile_index): 
			interseced_indices.append(new_pressed_tile_indices)
			continue
		_inner_tiles[pressed_tile_index.x][pressed_tile_index.y] = InnerTile.BLANK
		released_index_to_tiles[pressed_tile_index] = (
			get_tile(pressed_tile_index.x, pressed_tile_index.y)
			)
	
	if not released_index_to_tiles.empty():
		emit_signal("tiles_released", released_index_to_tiles)
	
	# press non-intersected new indices
	var pressed_index_to_tiles = {}
	for new_pressed_tile_index in new_pressed_tile_indices:
		if interseced_indices.has(new_pressed_tile_index): continue
		_inner_tiles[new_pressed_tile_index.x][new_pressed_tile_index.y] = InnerTile.PRESSED
		pressed_index_to_tiles[new_pressed_tile_index] = (
			get_tile(new_pressed_tile_index.x, new_pressed_tile_index.y)
			)
	if not pressed_index_to_tiles.empty():
		emit_signal("tiles_pressed", pressed_index_to_tiles)
	
	# update _pressed_tile_indices
	_pressed_tile_indices = new_pressed_tile_indices

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
				InnerTile.PRESSED: format = "(%s)"
				InnerTile.REVEALED: format = " %s "
			match mine_map_tile:
				-1: tile_to_print = format % ["*"]
				_: tile_to_print = format % [str(mine_map_tile)]
			to_print += tile_to_print
			if x == get_size_x() - 1: to_print += "\n"
	return to_print
