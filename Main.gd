extends Node2D

export(NodePath) onready var board = get_node(board) as TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Tile { BLANK = 12, FLAG, MINE, N0, N1, N2, N3, N4, N5, N6, N7, N8 }

const _board_size := Vector2(30, 16)
const _mine_count := 99
const _tile_size := 16.0
const _window_ratio := 3.0

var _mine_map := MineMap.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var board_size_pixel = _board_size * _tile_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, board_size_pixel)
	OS.window_size = board_size_pixel * _window_ratio
	
	randomize()
	_update_board(_board_size, _mine_count)

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_select"):
		_update_board(_board_size, _mine_count)

func _update_board(size: Vector2, mine_count: int):
	_mine_map.generate(size.x, size.y, mine_count)
	print(_mine_map)
	for x in range(_mine_map.get_size_x()):
		for y in range(_mine_map.get_size_y()):
			var board_tile: int
			match _mine_map.get_tile(x, y):
				-1: board_tile = Tile.MINE
				0: board_tile = Tile.N0
				1: board_tile = Tile.N1
				2: board_tile = Tile.N2
				3: board_tile = Tile.N3
				4: board_tile = Tile.N4
				5: board_tile = Tile.N5
				6: board_tile = Tile.N6
				7: board_tile = Tile.N7
				8: board_tile = Tile.N8
				_: board_tile = Tile.FLAG
			board.set_cell(x, y, board_tile)
