extends Node2D


signal pc_attacked(message)

const DungeonBoard := preload("res://scene/main/DungeonBoard.gd")
const RemoveObject := preload("res://scene/main/RemoveObject.gd")
const Schedule := preload("res://scene/main/Schedule.gd")

var _ref_DungeonBoard: DungeonBoard
var _ref_RemoveObject: RemoveObject
var _ref_Schedule: Schedule


func attack(main_group: String, x: int, y: int) -> void:
	if not _ref_DungeonBoard.has_sprite(main_group, x, y):
		return
	_ref_RemoveObject.remove(main_group, x, y)
	_ref_Schedule.end_turn()
	emit_signal("pc_attacked", "You kill Urist McRogueliker! :(")
