extends Node2D

export(NodePath) onready var board = get_node(board) as TileMap

const _board_size := Vector2(9, 9)
const _mine_count := 10
const _tile_size := 16.0
const _window_ratio := 3.0

var _mine_map := HiddenMineMap.new()

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
	board.show_map(_mine_map)
