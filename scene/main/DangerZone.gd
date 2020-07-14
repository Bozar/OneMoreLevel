extends Node2D


var _new_DungeonSize := preload("res://library/DungeonSize.gd").new()
var _new_CoordCalculator := preload("res://library/CoordCalculator.gd").new()

# <x: int, <y: int, state: bool>>
var _coord_to_state: Dictionary = {}


func _ready() -> void:
	for x in range(_new_DungeonSize.MAX_X):
		_coord_to_state[x] = []
		for _y in range(_new_DungeonSize.MAX_Y):
			_coord_to_state[x].push_back(false)


func is_in_danger(x: int, y: int) -> bool:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return true
	return _coord_to_state[x][y]


func set_danger_zone(x: int, y: int, is_dangerous: bool) -> void:
	if not _new_CoordCalculator.is_inside_dungeon(x, y):
		return
	_coord_to_state[x][y] = is_dangerous
