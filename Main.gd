extends Node2D

export(NodePath) onready var board = get_node(board) as TileMap

const _tile_size := 16.0
const _window_ratio := 3.0

var _board_settings := BoardSettings.new()

var _mine_map := HiddenMineMap.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_board_settings.change_to_expert()
	_update_board()

func _update_board():
	var board_size = _board_settings.board_size
	var board_size_pixel = board_size * _tile_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, board_size_pixel)
	OS.window_size = board_size_pixel * _window_ratio
	
	_mine_map.generate(board_size.x, board_size.y, _board_settings.mine_count)
	board.show_map(_mine_map)

func _unhandled_input(event):
	if Input.is_action_just_pressed("restart"):
		_update_board()
	if Input.is_action_just_pressed("restart_beginner"):
		_board_settings.change_to_beginner()
		_update_board()
	if Input.is_action_just_pressed("restart_intermediate"):
		_board_settings.change_to_intermediate()
		_update_board()
	if Input.is_action_just_pressed("restart_expert"):
		_board_settings.change_to_expert()
		_update_board()
