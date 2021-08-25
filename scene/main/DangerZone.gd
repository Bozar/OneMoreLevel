extends Node2D
class_name Game_DangerZone


# <x: int, <y: int, state: int>>
var _coord_to_state: Dictionary = {}


func _ready() -> void:
	for x in range(Game_DungeonSize.MAX_X):
		_coord_to_state[x] = []
		for _y in range(Game_DungeonSize.MAX_Y):
			_coord_to_state[x].push_back(0)


func is_in_danger(x: int, y: int) -> bool:
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return true
	return _coord_to_state[x][y] > 0


func set_danger_zone(x: int, y: int, is_dangerous: bool) -> void:
	if not Game_CoordCalculator.is_inside_dungeon(x, y):
		return

	if is_dangerous:
		_coord_to_state[x][y] += 1
	else:
		if _coord_to_state[x][y] > 0:
			_coord_to_state[x][y] -= 1
