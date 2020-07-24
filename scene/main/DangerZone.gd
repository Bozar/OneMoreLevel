extends Node2D


var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

# <x: int, <y: int, state: int>>
var _coord_to_state: Dictionary = {}


func _ready() -> void:
	for x in range(_new_DungeonSize.MAX_X):
		_coord_to_state[x] = []
		for _y in range(_new_DungeonSize.MAX_Y):
			_coord_to_state[x].push_back(0)


func is_in_danger(x: int, y: int) -> bool:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return true
	return _coord_to_state[x][y] > 0


func set_danger_zone(x: int, y: int, is_dangerous: bool) -> void:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return

	if is_dangerous:
		_coord_to_state[x][y] += 1
	else:
		if _coord_to_state[x][y] > 0:
			_coord_to_state[x][y] -= 1
