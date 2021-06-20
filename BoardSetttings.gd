class_name BoardSettings
extends Node

var board_size := Vector2.ZERO
var mine_count := 0

func change_to_beginner():
	board_size = Vector2(9, 9)
	mine_count = 9

func change_to_intermediate():
	board_size = Vector2(16, 16)
	mine_count = 40

func change_to_expert():
	board_size = Vector2(30, 16)
	mine_count = 99

func change_to_custom(board_size: Vector2, mine_count: int):
	self.board_size = board_size
	self.mine_count = mine_count
